# ---------
# PHP stage
# ---------
FROM d3strukt0r/wordpress-php AS php

RUN set -eux; \
    \
    wp-plugin-install \
        advanced-code-editor \
        contact-form-7 \
        disqus-comment-system \
        facebook-for-woocommerce \
        fancybox-for-wordpress \
        gift-cards-for-woocommerce \
        google-analytics-for-wordpress \
        homepage-control \
        jetpack \
        polylang \
        press-tab-to-search \
        timber-library \
        tinymce-advanced \
        woo-gutenberg-products-block \
        woocommerce \
        woocommerce-admin \
        woocommerce-coupon-shortcodes \
        woocommerce-customizer \
        woocommerce-eu-vat-compliance \
        woocommerce-gateway-amazon-payments-advanced \
        woocommerce-gateway-paypal-express-checkout \
        woocommerce-gateway-paypal-powered-by-braintree \
        woocommerce-google-analytics-integration \
        woocommerce-pdf-invoices-packing-slips \
        wordpress-importer \
        wordpress-seo \
        wp-mail-smtp \
        yith-essential-kit-for-woocommerce-1 \
        yith-woocommerce-advanced-reviews \
        yith-woocommerce-eu-vat \
        yith-woocommerce-order-tracking \
        yith-woocommerce-request-a-quote; \
    \
    wp-theme-install \
        customify \
        radcliffe \
        storefront \
        twentynineteen; \
    \
    # Fix permission
    chown www-data:www-data -R .; \
    find . -type d -exec chmod 755 {} \;; \
    find . -type f -exec chmod 644 {} \;

# -----------
# Nginx stage
# -----------
FROM d3strukt0r/wordpress-nginx AS nginx

COPY --from=php /app /app

RUN set -eux; \
    \
    find . -type f -name "*.php" -exec sh -c 'i="$1"; >"$i"' _ {} \;
