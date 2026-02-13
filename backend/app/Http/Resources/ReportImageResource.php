<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin \App\Models\ReportImage
 */
class ReportImageResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reportId' => $this->report_id,
            'path' => $this->path,
            'url' => $this->url,
            'mime' => $this->mime,
            'size' => $this->size,
            'createdAt' => optional($this->created_at)->toISOString(),
        ];
    }
}

