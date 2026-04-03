<?php
/**
 * Plugin Name: Static Export on Publish
 * Description: Automatically triggers Simply Static export when a post/page is published or updated.
 * Auto-loaded as a must-use plugin (mu-plugin) — no activation needed.
 */

add_action( 'transition_post_status', 'trigger_static_export_on_publish', 10, 3 );

function trigger_static_export_on_publish( $new_status, $old_status, $post ) {
    // Only fire when transitioning TO published
    if ( $new_status !== 'publish' ) {
        return;
    }
    // Only for public post types
    $public_types = get_post_types( ['public' => true] );
    if ( ! in_array( $post->post_type, $public_types ) ) {
        return;
    }

    // Trigger Simply Static export via its action hook (if plugin is active)
    if ( class_exists( 'Simply_Static\Plugin' ) ) {
        do_action( 'simply_static_export' );
        error_log( '[Static Export] Triggered Simply Static export for post ID: ' . $post->ID );
    } else {
        error_log( '[Static Export] Simply Static plugin not found. Install it with: docker compose run --rm wpcli wp plugin install simply-static --activate' );
    }
}
