#!/bin/sh

cd /var/www/html

#adduser -S www-data -G www-data 2>/dev/null || true
chown -R www-data:www-data /var/www/html

if [ ! -f /var/www/html/index.php ]; then
    tar -xzf /tmp/wp.tar.gz -C /var/www/html --strip-components=1
fi


# Read database password from files
if [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
else
    echo "Error: WORDPRESS_DB_PASSWORD_FILE is not set or file does not exist."
    exit 1
fi

if [ -f "$WORDPRESS_ADMIN_PASSWORD_FILE" ]; then
    WORDPRESS_ADMIN_PASSWORD=$(cat "$WORDPRESS_ADMIN_PASSWORD_FILE")
else
    echo "Error: WORDPRESS_ADMIN_PASSWORD_FILE is not set or file does not exist."
    exit 1
fi

if [ -f "$WORDPRESS_USER_PASSWORD_FILE" ]; then
   WORDPRESS_USER_PASSWORD=$(cat "$WORDPRESS_USER_PASSWORD_FILE")
else
    echo "Error: WORDPRESS_USER_PASSWORD_FILE is not set or file does not exist."
    exit 1
fi

DB_HOST="$WORDPRESS_DB_HOST:$WORDPRESS_DB_PORT"

until mysqladmin ping -h"$WORDPRESS_DB_HOST" -P "$WORDPRESS_DB_PORT" --silent 2>/dev/null; do
    echo "Waiting for database connection..."
    sleep 2
done

if [ ! -f wp-config.php ]; then
    echo "Installing wordpress..."
    
    wp config create --allow-root \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$DB_HOST \
        --path=/var/www/html
        
    wp core install --allow-root \
        --url=$WORDPRESS_DB_URL \
        --title=$WORDPRESS_SITE_NAME \
        --admin_user=$WORDPRESS_ADMIN_USER \
        --admin_password=$WORDPRESS_ADMIN_PASSWORD \
        --admin_email=$WORDPRESS_ADMIN_EMAIL --path=/var/www/html
    echo "WordPress is installed!"

    echo "Creating user and customizing pages..."

    # Create the user
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --role=author \
        --user_pass="$WORDPRESS_USER_PASSWORD" \
        --path=/var/www/html \
        --allow-root

    # Delete existing pages and posts
    PAGE_IDS=$(wp post list --post_type=page --format=ids --allow-root --path=/var/www/html)
    POST_IDS=$(wp post list --post_type=post --format=ids --allow-root --path=/var/www/html)

    [ -n "$PAGE_IDS" ] && wp post delete $PAGE_IDS --force --allow-root --path=/var/www/html
    [ -n "$POST_IDS" ] && wp post delete $POST_IDS --force --allow-root --path=/var/www/html

    # Create the "Comments Board" post
    COMMENT_POST_ID=$(wp post create \
        --post_type=post \
        --post_title='Comments Board' \
        --post_content='This is the comment board. Feel free to leave a comment!' \
        --comment_status=open \
        --post_status=publish \
        --post_author="$WORDPRESS_USER" \
        --porcelain --allow-root --path=/var/www/html)

    # Create the "Inception Project" page (this will be the front page)
    POST_ID=$(wp post create --post_type=page --post_title='Inception Project' \
        --post_content='Inception web page by thelee' \
        --post_author="$WORDPRESS_USER" \
        --post_status=publish --porcelain --allow-root --path=/var/www/html)

    # Set the front page to the "Inception Project" page
    wp option update show_on_front 'page' --allow-root --path=/var/www/html
    wp option update page_on_front $POST_ID --allow-root --path=/var/www/html

    # Optionally, set the "Comments Board" post as a blog page (or for posts)
    BLOG_PAGE_ID=$(wp post create --post_type=page --post_title='Posts' --post_author="$WORDPRESS_USER" \
        --post_status=publish --porcelain --allow-root --path=/var/www/html)

    wp option update page_for_posts $BLOG_PAGE_ID --allow-root --path=/var/www/html

    echo "User created and WordPress customization complete!"
fi
chown -R www-data:www-data /var/www/html

exec "$@"