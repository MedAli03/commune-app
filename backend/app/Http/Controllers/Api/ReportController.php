<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreReportRequest;
use App\Http\Resources\ReportResource;
use App\Models\Report;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Str;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $perPage = min(max((int) $request->query('perPage', 20), 1), 100);
        $page = max((int) $request->query('page', 1), 1);

        $allowedSortBy = ['created_at', 'title'];
        $sortBy = $request->query('sortBy', 'created_at');
        if (! in_array($sortBy, $allowedSortBy, true)) {
            $sortBy = 'created_at';
        }

        $sortDirection = strtolower((string) $request->query('sortDirection', 'desc'));
        if (! in_array($sortDirection, ['asc', 'desc'], true)) {
            $sortDirection = 'desc';
        }

        $search = trim((string) $request->query('search', ''));

        $query = Report::query();

        if ($search !== '') {
            $query->where(function ($builder) use ($search): void {
                $builder
                    ->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $reports = $query
            ->orderBy($sortBy, $sortDirection)
            ->forPage($page, $perPage)
            ->get();

        return ReportResource::collection($reports);
    }

    public function show(string $id): ReportResource|JsonResponse
    {
        $report = Report::query()->find($id);

        if ($report === null) {
            return response()->json([
                'message' => 'Report not found',
            ], 404);
        }

        return new ReportResource($report);
    }

    public function store(StoreReportRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $report = Report::query()->create([
            'id' => $validated['id'] ?? (string) Str::uuid(),
            'title' => $validated['title'],
            'description' => $validated['description'],
            'photo_path' => $validated['photoPath'] ?? null,
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'created_at_client' => $validated['createdAt'] ?? null,
        ]);

        return (new ReportResource($report))
            ->response()
            ->setStatusCode(201);
    }

    public function destroy(string $id): JsonResponse|Response
    {
        $report = Report::query()->find($id);

        if ($report === null) {
            return response()->json([
                'message' => 'Report not found',
            ], 404);
        }

        $paths = [];

        DB::transaction(function () use ($report, &$paths): void {
            $paths = $report->images()->pluck('path')->filter()->values()->all();
            $report->delete();
        });

        if ($paths !== []) {
            try {
                Storage::disk('public')->delete($paths);
            } catch (\Throwable) {
                // Best effort cleanup. Missing files should not fail request.
            }
        }

        return response()->noContent();
    }
}
