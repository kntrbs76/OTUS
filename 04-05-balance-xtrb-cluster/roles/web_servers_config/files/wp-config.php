<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wp' );

/** MySQL database username */
define( 'DB_USER', 'wpuser' );

/** MySQL database password */
define( 'DB_PASSWORD', 'wppassword' );

/** MySQL hostname */
define( 'DB_HOST', '10.0.0.20:6033' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'Ihfny0H~.$.HHHt,~5u,{<d4|w2srQ_;Rz.<TONHx+H85G{)7&`U GkK*7XK-=zv' );
define( 'SECURE_AUTH_KEY',  'W2?v/1;L|0ouYAKI:7)3$x?VQR$pp- iC8Yz#aPr5;p@xjEM^Wp@j;6GbZx}Lyx)' );
define( 'LOGGED_IN_KEY',    'G] I_7;-S~@UdSR6yUr1<ObV@jXYDVhLJ1^3Xl:+EkmePg%q0N gx5p2:vt(IIQA' );
define( 'NONCE_KEY',        'jS)7Y0&#sGR3;(4u1q-bFBvJe+sB<s5MdZsd)!z|]?adMo/IX$m@(ah7;x#z8oJy' );
define( 'AUTH_SALT',        'B5D1`OB7nzZW59T:`<dpoY0h[okQLyzCYlX]5k><V=v%wDw4a%_;u&K8-Xu,UgXV' );
define( 'SECURE_AUTH_SALT', 'nkw-WO}%afcmA^(iXGV}`pR5ym}>2((v~bAzb]XZ]D:PKjw[7hS}6Dfz@^&+sHZ4' );
define( 'LOGGED_IN_SALT',   '-<*Nuv7tGv_OE/!kYAfaB,H88PNKA|.Z0J/g.-P[k-a{40yB_&BTaK0sEPswH{vF' );
define( 'NONCE_SALT',       'trM78(yf*x0tL?(yF<ZG.g<t!:S.O#(o,:*oBw59E&@lh52*9e@<08r;Obc j%zt' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';