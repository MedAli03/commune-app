<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReportController extends Controller
{
    public function index(): JsonResponse
    {
        $reports = Report::query()
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (Report $report) => $report->toApiArray())
            ->values();

        return response()->json($reports);
    }

    public function show(string $id): JsonResponse
    {
        $report = Report::query()->find($id);

        if (!$report) {
            return response()->json(['message' => 'Report not found.'], 404);
        }

        return response()->json($report->toApiArray());
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'id' => ['required', 'string', 'min:1'],
            'title' => ['required', 'string', 'min:1'],
            'description' => ['required', 'string', 'min:1'],
            'photoPath' => ['nullable', 'string'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'createdAt' => ['nullable', 'date'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed.',
                'details' => $validator->errors()->all(),
            ], 400);
        }

        $validated = $validator->validated();

        $report = new Report();
        $report->id = trim($validated['id']);
        $report->title = trim($validated['title']);
        $report->description = trim($validated['description']);
        $report->photo_path = $validated['photoPath'] ?? null;
        $report->latitude = array_key_exists('latitude', $validated) ? (float) $validated['latitude'] : null;
        $report->longitude = array_key_exists('longitude', $validated) ? (float) $validated['longitude'] : null;

        if (!empty($validated['createdAt'])) {
            $report->created_at = $validated['createdAt'];
        }

        $report->save();

        return response()->json($report->fresh()->toApiArray(), 201);
    }

    public function destroy(string $id): JsonResponse
    {
        $report = Report::query()->find($id);

        if (!$report) {
            return response()->json(['message' => 'Report not found.'], 404);
        }

        $report->delete();

        return response()->json(null, 204);
    }
}
