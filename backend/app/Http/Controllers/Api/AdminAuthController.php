<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\AdminLoginRequest;
use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminAuthController extends Controller
{
    public function login(AdminLoginRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $admin = User::query()
            ->where('username', $validated['username'])
            ->where('is_admin', true)
            ->first();

        if ($admin === null || ! Hash::check($validated['password'], $admin->password)) {
            return response()->json([
                'message' => 'Invalid username or password',
            ], 422);
        }

        $token = $admin->createToken('admin-api')->plainTextToken;

        return response()->json([
            'token' => $token,
            'admin' => $this->adminPayload($admin),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Logged out',
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        /** @var User $admin */
        $admin = $request->user();

        return response()->json([
            'admin' => $this->adminPayload($admin),
        ]);
    }

    /**
     * @return array{id:int,username:string|null}
     */
    private function adminPayload(User $admin): array
    {
        return [
            'id' => $admin->id,
            'username' => $admin->username,
        ];
    }
}
