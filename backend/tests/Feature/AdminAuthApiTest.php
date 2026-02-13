<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminAuthApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_login_success_returns_token_and_admin_payload(): void
    {
        User::factory()->create([
            'username' => 'admin',
            'password' => 'Admin@12345',
            'is_admin' => true,
        ]);

        $response = $this->postJson('/admin/login', [
            'username' => 'admin',
            'password' => 'Admin@12345',
        ]);

        $response
            ->assertOk()
            ->assertJsonStructure([
                'token',
                'admin' => ['id', 'username'],
            ])
            ->assertJsonPath('admin.username', 'admin');
    }

    public function test_admin_login_failure_returns_error_message(): void
    {
        User::factory()->create([
            'username' => 'admin',
            'password' => 'Admin@12345',
            'is_admin' => true,
        ]);

        $this->postJson('/admin/login', [
            'username' => 'admin',
            'password' => 'wrong-password',
        ])
            ->assertStatus(422)
            ->assertJson([
                'message' => 'Invalid username or password',
            ]);
    }
}
