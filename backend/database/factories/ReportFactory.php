<?php

namespace Database\Factories;

use App\Models\Report;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Report>
 */
class ReportFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var class-string<\App\Models\Report>
     */
    protected $model = Report::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'id' => (string) Str::uuid(),
            'title' => fake()->sentence(6),
            'description' => fake()->paragraph(2),
            'photo_path' => fake()->boolean(35) ? '/storage/reports/'.fake()->uuid().'.jpg' : null,
            'latitude' => fake()->optional(0.85)->latitude(),
            'longitude' => fake()->optional(0.85)->longitude(),
            'created_at_client' => fake()->optional(0.7)->dateTimeBetween('-30 days', 'now'),
        ];
    }
}

