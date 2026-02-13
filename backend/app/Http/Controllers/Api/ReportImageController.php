<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreReportImageRequest;
use App\Http\Resources\ReportImageResource;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class ReportImageController extends Controller
{
    public function store(StoreReportImageRequest $request, string $id): JsonResponse
    {
        if (($forbidden = $this->forbiddenUnlessAdmin($request)) !== null) {
            return $forbidden;
        }

        $report = Report::query()->find($id);

        if ($report === null) {
            return response()->json([
                'message' => 'Report not found',
            ], 404);
        }

        $file = $request->file('image') ?? $request->file('file');
        $path = $file->store("reports/{$report->id}", 'public');

        $image = $report->images()->create([
            'path' => $path,
            'url' => Storage::disk('public')->url($path),
            'mime' => $file->getClientMimeType() ?? 'application/octet-stream',
            'size' => $file->getSize() ?? 0,
        ]);

        return response()->json((new ReportImageResource($image))->resolve(), 201);
    }

    public function destroy(Request $request, string $id, int $imageId): JsonResponse|Response
    {
        if (($forbidden = $this->forbiddenUnlessAdmin($request)) !== null) {
            return $forbidden;
        }

        $report = Report::query()->find($id);

        if ($report === null) {
            return response()->json([
                'message' => 'Report not found',
            ], 404);
        }

        $image = $report->images()->whereKey($imageId)->first();

        if ($image === null) {
            return response()->json([
                'message' => 'Image not found',
            ], 404);
        }

        $path = $image->path;

        DB::transaction(function () use ($image): void {
            $image->delete();
        });

        try {
            Storage::disk('public')->delete($path);
        } catch (\Throwable) {
            // Best effort cleanup. Missing files should not fail request.
        }

        return response()->noContent();
    }

    private function forbiddenUnlessAdmin(Request $request): ?JsonResponse
    {
        $user = $request->user();

        if ($user instanceof User && Gate::forUser($user)->allows('admin-only')) {
            return null;
        }

        return response()->json([
            'message' => 'Forbidden',
            'details' => null,
        ], 403);
    }
}
