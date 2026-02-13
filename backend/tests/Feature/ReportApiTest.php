<?php

namespace Tests\Feature;

use App\Models\Report;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ReportApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_get_reports_returns_expected_shape(): void
    {
        Report::factory()->count(2)->create();

        $response = $this->getJson('/reports');

        $response
            ->assertOk()
            ->assertJsonIsArray()
            ->assertJsonStructure([
                '*' => ['id', 'title', 'description', 'photoPath', 'latitude', 'longitude', 'createdAt'],
            ]);
    }

    public function test_get_report_by_id_returns_200_for_existing_and_404_for_missing(): void
    {
        $report = Report::factory()->create();

        $this->getJson('/reports/'.$report->id)
            ->assertOk()
            ->assertJsonStructure(['id', 'title', 'description', 'photoPath', 'latitude', 'longitude', 'createdAt']);

        $this->getJson('/reports/non-existent-id')
            ->assertNotFound()
            ->assertJson([
                'message' => 'Report not found',
            ]);
    }

    public function test_post_reports_creates_report_anonymously(): void
    {
        $payload = [
            'title' => 'Unsafe sidewalk segment',
            'description' => 'The sidewalk surface is damaged and unsafe for pedestrians.',
            'photoPath' => '/storage/emulated/0/Pictures/sidewalk.jpg',
            'latitude' => 24.7212,
            'longitude' => 46.6823,
            'createdAt' => '2026-02-13T09:45:00Z',
        ];

        $response = $this->postJson('/reports', $payload);

        $response
            ->assertCreated()
            ->assertJsonPath('title', $payload['title'])
            ->assertJsonPath('description', $payload['description'])
            ->assertJsonPath('photoPath', $payload['photoPath'])
            ->assertJsonStructure(['id', 'title', 'description', 'photoPath', 'latitude', 'longitude', 'createdAt']);

        $this->assertDatabaseHas('reports', [
            'title' => $payload['title'],
            'description' => $payload['description'],
            'photo_path' => $payload['photoPath'],
        ]);
    }

    public function test_post_reports_validation_error_returns_message_and_details(): void
    {
        $response = $this->postJson('/reports', [
            'title' => 'bad',
            'description' => 'short',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonStructure(['message', 'details']);

        $this->assertIsArray($response->json('details'));
        $this->assertNotEmpty($response->json('details'));
    }

    public function test_delete_report_deletes_and_returns_expected_response(): void
    {
        $report = Report::factory()->create();

        $this->deleteJson('/reports/'.$report->id)
            ->assertNoContent();

        $this->assertDatabaseMissing('reports', [
            'id' => $report->id,
        ]);
    }

    public function test_post_images_upload_stores_file_and_returns_expected_shape(): void
    {
        Storage::fake('public');
        $report = Report::factory()->create();

        $response = $this->post('/reports/'.$report->id.'/images', [
            'image' => UploadedFile::fake()->create('report-image.jpg', 120, 'image/jpeg'),
        ], [
            'Accept' => 'application/json',
        ]);

        $response
            ->assertCreated()
            ->assertJsonStructure(['id', 'reportId', 'path', 'url', 'mime', 'size', 'createdAt'])
            ->assertJsonPath('reportId', $report->id);

        $path = $response->json('path');

        Storage::disk('public')->assertExists($path);
        $this->assertDatabaseHas('report_images', [
            'report_id' => $report->id,
            'path' => $path,
        ]);
    }
}
