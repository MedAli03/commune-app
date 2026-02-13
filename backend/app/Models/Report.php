<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Report extends Model
{
    use HasFactory;

    public const STATUS_NEW = 'new';
    public const STATUS_IN_PROGRESS = 'inProgress';
    public const STATUS_RESOLVED = 'resolved';

    /**
     * The primary key type is UUID.
     *
     * @var string
     */
    protected $keyType = 'string';

    /**
     * Disable auto-increment for UUID primary key.
     *
     * @var bool
     */
    public $incrementing = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'id',
        'title',
        'description',
        'status',
        'photo_path',
        'latitude',
        'longitude',
        'created_at_client',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'created_at_client' => 'datetime',
    ];

    /**
     * @return list<string>
     */
    public static function allowedStatuses(): array
    {
        return [
            self::STATUS_NEW,
            self::STATUS_IN_PROGRESS,
            self::STATUS_RESOLVED,
        ];
    }

    public function images(): HasMany
    {
        return $this->hasMany(ReportImage::class);
    }
}
