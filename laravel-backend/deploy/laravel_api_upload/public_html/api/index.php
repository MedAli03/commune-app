<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

require __DIR__.'/../laravel_api/vendor/autoload.php';

$app = require_once __DIR__.'/../laravel_api/bootstrap/app.php';

/** @var Application $app */
$app->handleRequest(Request::capture());
