<?php

use App\Http\Controllers\Api\ReportController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

Route::prefix('reports')->group(function () {
    Route::get('/', [ReportController::class, 'index']);
    Route::get('/{id}', [ReportController::class, 'show']);
    Route::post('/', [ReportController::class, 'store']);
    Route::delete('/{id}', [ReportController::class, 'destroy']);
});
