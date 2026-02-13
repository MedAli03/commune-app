<?php

use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\ReportImageController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

Route::prefix('reports')->group(function () {
    Route::get('/', [ReportController::class, 'index']);
    Route::get('/{id}', [ReportController::class, 'show']);
    Route::post('/', [ReportController::class, 'store']);
    Route::delete('/{id}', [ReportController::class, 'destroy']);
    Route::post('/{id}/images', [ReportImageController::class, 'store']);
    Route::delete('/{id}/images/{imageId}', [ReportImageController::class, 'destroy']);
});
