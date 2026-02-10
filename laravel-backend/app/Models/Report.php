<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    protected $table = 'reports';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'title',
        'description',
        'photo_path',
        'latitude',
        'longitude',
        'created_at',
    ];

    public $timestamps = true;

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function toApiArray(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'photoPath' => $this->photo_path,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'createdAt' => optional($this->created_at)->toISOString(),
        ];
    }
}
