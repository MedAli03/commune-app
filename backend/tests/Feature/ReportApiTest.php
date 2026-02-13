<?php

namespace Tests\Feature;

use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ReportApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_get_reports_requires_admin_authentication(): void
    {
        $this->getJson('/reports')
            ->assertUnauthorized()
            ->assertJsonStructure(['message']);
    }

    public function test_admin_can_get_reports_with_expected_shape(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        Sanctum::actingAs($admin);
        Report::factory()->count(2)->create();

        $this->getJson('/reports')
            ->assertOk()
            ->assertJsonIsArray()
            ->assertJsonStructure([
                '*' => ['id', 'title', 'description', 'status', 'photoPath', 'latitude', 'longitude', 'createdAt'],
            ]);
    }

    public function test_get_report_by_id_requires_admin_authentication(): void
    {
        $report = Report::factory()->create();

        $this->getJson('/reports/'.$report->id)
            ->assertUnauthorized()
            ->assertJsonStructure(['message']);
    }

    public function test_admin_get_report_by_id_returns_200_for_existing_and_404_for_missing(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        Sanctum::actingAs($admin);
        $report = Report::factory()->create();

        $this->getJson('/reports/'.$report->id)
            ->assertOk()
            ->assertJsonStructure(['id', 'title', 'description', 'status', 'photoPath', 'latitude', 'longitude', 'createdAt']);

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
            ->assertJsonPath('status', 'new')
            ->assertJsonPath('photoPath', $payload['photoPath'])
            ->assertJsonStructure(['id', 'title', 'description', 'status', 'photoPath', 'latitude', 'longitude', 'createdAt']);

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

    public function test_protected_report_actions_require_authentication(): void
    {
        $report = Report::factory()->create();

        $this->deleteJson('/reports/'.$report->id)
            ->assertUnauthorized()
            ->assertJsonStructure(['message']);

        $this->patchJson('/reports/'.$report->id.'/status', [
            'status' => Report::STATUS_RESOLVED,
        ])
            ->assertUnauthorized()
            ->assertJsonStructure(['message']);

        $this->postJson('/reports/'.$report->id.'/images', [
            'image' => UploadedFile::fake()->create('report-image.jpg', 120, 'image/jpeg'),
        ])
            ->assertUnauthorized()
            ->assertJsonStructure(['message']);
    }

    public function test_non_admin_token_cannot_manage_or_view_reports(): void
    {
        $user = User::factory()->create([
            'is_admin' => false,
        ]);
        Sanctum::actingAs($user);
        $report = Report::factory()->create();

        $this->getJson('/reports')
            ->assertForbidden()
            ->assertJson([
                'message' => 'Forbidden',
                'details' => null,
            ]);

        $this->getJson('/reports/'.$report->id)
            ->assertForbidden()
            ->assertJson([
                'message' => 'Forbidden',
                'details' => null,
            ]);

        $this->patchJson('/reports/'.$report->id.'/status', [
            'status' => Report::STATUS_RESOLVED,
        ])
            ->assertForbidden()
            ->assertJson([
                'message' => 'Forbidden',
                'details' => null,
            ]);

        $this->deleteJson('/reports/'.$report->id)
            ->assertForbidden()
            ->assertJson([
                'message' => 'Forbidden',
                'details' => null,
            ]);
    }

    public function test_status_update_works_with_token(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        Sanctum::actingAs($admin);
        $report = Report::factory()->create([
            'status' => Report::STATUS_NEW,
        ]);

        $response = $this->patchJson('/reports/'.$report->id.'/status', [
            'status' => Report::STATUS_RESOLVED,
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('id', $report->id)
            ->assertJsonPath('status', Report::STATUS_RESOLVED);

        $this->assertDatabaseHas('reports', [
            'id' => $report->id,
            'status' => Report::STATUS_RESOLVED,
        ]);
    }

    public function test_delete_report_deletes_and_returns_expected_response_with_token(): void
    {
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        Sanctum::actingAs($admin);
        $report = Report::factory()->create();

        $this->deleteJson('/reports/'.$report->id)->assertNoContent();

        $this->assertDatabaseMissing('reports', ['id' => $report->id]);
    }

    public function test_post_images_upload_stores_file_and_returns_expected_shape_with_token(): void
    {
        Storage::fake('public');
        $admin = User::factory()->create([
            'is_admin' => true,
        ]);
        Sanctum::actingAs($admin);
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
