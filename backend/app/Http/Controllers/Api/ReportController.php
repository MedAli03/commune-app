<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class ReportController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'message' => 'Not implemented',
        ], 501);
    }

    public function show(string $id): JsonResponse
    {
        return response()->json([
            'message' => 'Not implemented',
        ], 501);
    }

    public function store(): JsonResponse
    {
        return response()->json([
            'message' => 'Not implemented',
        ], 501);
    }

    public function destroy(string $id): JsonResponse
    {
        return response()->json([
            'message' => 'Not implemented',
        ], 501);
    }
}

