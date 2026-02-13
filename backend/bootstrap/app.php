<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        apiPrefix: '',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->api(append: [\App\Http\Middleware\ForceJsonResponse::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (ValidationException $e, Request $request) {
            if (! $request->expectsJson()) {
                return null;
            }

            $details = collect($e->errors())->flatten()->values()->all();

            return response()->json([
                'message' => 'Validation failed',
                'details' => $details,
            ], $e->status);
        });

        $exceptions->render(function (\Throwable $e, Request $request) {
            if (! $request->expectsJson()) {
                return null;
            }

            $status = $e instanceof HttpExceptionInterface ? $e->getStatusCode() : 500;

            $message = trim($e->getMessage());
            if ($message === '') {
                $message = SymfonyResponse::$statusTexts[$status] ?? 'Server error';
            }

            return response()->json([
                'message' => $message,
            ], $status);
        });
    })->create();
