<?php

namespace Database\Seeders;

use App\Models\Report;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class ReportSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $rows = [
            [
                'id' => '1ddc3e4d-0f7a-4066-8b4c-7c8cc21ad001',
                'title' => 'Broken streetlight near school gate',
                'description' => 'Streetlight has been off for three nights near the school entrance.',
                'status' => Report::STATUS_NEW,
                'photo_path' => null,
                'latitude' => 24.7136000,
                'longitude' => 46.6753000,
                'created_at_client' => Carbon::parse('2026-02-10 18:20:00'),
                'created_at' => Carbon::parse('2026-02-10 18:22:00'),
                'updated_at' => Carbon::parse('2026-02-10 18:22:00'),
            ],
            [
                'id' => '2a73b1d9-f44b-41ad-9b31-3b6dbef4c002',
                'title' => 'Large pothole on main avenue',
                'description' => 'A deep pothole is causing cars to swerve and blocking one lane.',
                'status' => Report::STATUS_IN_PROGRESS,
                'photo_path' => '/storage/emulated/0/Pictures/pothole-main-ave.jpg',
                'latitude' => 24.7194000,
                'longitude' => 46.6812000,
                'created_at_client' => Carbon::parse('2026-02-11 07:45:00'),
                'created_at' => Carbon::parse('2026-02-11 07:46:00'),
                'updated_at' => Carbon::parse('2026-02-11 07:46:00'),
            ],
            [
                'id' => '3f86aa2e-d22a-473f-a298-5dc6108bd003',
                'title' => 'Overflowing waste container',
                'description' => 'The public waste container is overflowing and trash is spread around.',
                'status' => Report::STATUS_NEW,
                'photo_path' => null,
                'latitude' => 24.7051000,
                'longitude' => 46.6628000,
                'created_at_client' => null,
                'created_at' => Carbon::parse('2026-02-11 13:10:00'),
                'updated_at' => Carbon::parse('2026-02-11 13:10:00'),
            ],
            [
                'id' => '47a7f62b-f8aa-4cb8-9e72-0975f8d7c004',
                'title' => 'Illegal dumping behind market',
                'description' => 'Construction debris has been dumped behind the market parking area.',
                'status' => Report::STATUS_RESOLVED,
                'photo_path' => '/storage/emulated/0/Pictures/dumping-market.png',
                'latitude' => 24.7310000,
                'longitude' => 46.7019000,
                'created_at_client' => Carbon::parse('2026-02-12 09:30:00'),
                'created_at' => Carbon::parse('2026-02-12 09:32:00'),
                'updated_at' => Carbon::parse('2026-02-12 09:32:00'),
            ],
            [
                'id' => '5b2c2443-bd0e-4726-9b68-3e0be8fda005',
                'title' => 'Damaged pedestrian crossing sign',
                'description' => 'The crossing sign is bent and barely visible to incoming traffic.',
                'status' => Report::STATUS_IN_PROGRESS,
                'photo_path' => null,
                'latitude' => null,
                'longitude' => null,
                'created_at_client' => Carbon::parse('2026-02-12 16:50:00'),
                'created_at' => Carbon::parse('2026-02-12 16:53:00'),
                'updated_at' => Carbon::parse('2026-02-12 16:53:00'),
            ],
        ];

        Report::query()->upsert(
            $rows,
            ['id'],
            ['title', 'description', 'status', 'photo_path', 'latitude', 'longitude', 'created_at_client', 'created_at', 'updated_at']
        );
    }
}
