<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    public function index(): JsonResponse
    {
        DB::select('SELECT 1');

        return response()->json([
            'ok' => true,
            'db' => true,
        ]);
    }
}
