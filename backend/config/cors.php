<?php

return [
    // API routes are mounted at root (no /api prefix).
    'paths' => [
        'admin/*',
        'reports*',
        'health',
        'up',
        'storage/*',
        'sanctum/csrf-cookie',
    ],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        'http://10.0.2.2:3000',
    ],

    'allowed_origins_patterns' => [
        '#^https?://localhost(:\d+)?$#',
        '#^https?://127\.0\.0\.1(:\d+)?$#',
    ],

    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,
];
