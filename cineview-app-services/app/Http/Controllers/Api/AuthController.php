<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{

    /**
     * Get All Users
     * 
     * Mengambil daftar semua user yang terdaftar di sistem.
     * 
     * @response 200 {
     *   "data": [
     *     {"id": 1, "name": "John Doe", "email": "john@example.com", "profile_photo": null},
     *     {"id": 2, "name": "Jane Doe", "email": "jane@example.com", "profile_photo": null}
     *   ]
     * }
     */
    public function index()
    {
        return response()->json([
            'data' => User::all()
        ]);
    }

    /**
     * Register User
     * 
     * Mendaftarkan user baru ke sistem CineView dan mengembalikan token akses.
     * 
     * @bodyParam name string required Nama lengkap user. Example: John Doe
     * @bodyParam email string required Email user (harus unik). Example: john@example.com
     * @bodyParam password string required Password minimal 8 karakter. Example: password123
     * @bodyParam password_confirmation string required Konfirmasi password. Example: password123
     * 
     * @response 201 {
     *   "message": "Registration successfull",
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"},
     *   "token": "1|abc123..."
     * }
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registration successfull',
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    /**
     * Login User
     * 
     * Melakukan autentikasi user dan mengembalikan token akses.
     * 
     * @bodyParam email string required Email user yang terdaftar. Example: john@example.com
     * @bodyParam password string required Password user. Example: password123
     * 
     * @response 200 {
     *   "message": "Login succesfull",
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"},
     *   "token": "1|abc123..."
     * }
     * @response 401 {
     *   "message": "Invalid credentials"
     * }
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials',
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login succesfull',
            'user' => $user,
            'token' => $token,
        ]);
    }

    /**
     * Logout User
     * 
     * Menghapus token akses user yang sedang login. Memerlukan Bearer Token.
     * 
     * @authenticated
     * 
     * @response 200 {
     *   "message": "Logout succesfull"
     * }
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout succesfull',
        ]);
    }

    /**
     * Get User Profile
     * 
     * Mengambil data profile user yang sedang login.
     * 
     * @authenticated
     * 
     * @response 200 {
     *   "user": {"id": 1, "name": "John Doe", "email": "john@example.com"}
     * }
     */
    public function getProfile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }

    /**
     * Update User Profile
     * 
     * Mengupdate data profile user yang sedang login.
     * 
     * @authenticated
     * @bodyParam name string required Nama baru user. Example: John Updated
     * 
     * @response 200 {
     *   "message": "Profile updated successfully",
     *   "user": {"id": 1, "name": "John Updated", "email": "john@example.com"}
     * }
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'profile_photo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'],
        ]);

        $user = $request->user();
        $user->name = $request->name;

        // Handle profile photo upload
        if ($request->hasFile('profile_photo')) {
            // Delete old photo if exists
            if ($user->profile_photo && \Storage::disk('public')->exists($user->profile_photo)) {
                \Storage::disk('public')->delete($user->profile_photo);
            }

            // Store new photo
            $path = $request->file('profile_photo')->store('profile_photos', 'public');
            $user->profile_photo = $path;
        }

        $user->save();

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    /**
     * Change Password
     * 
     * Mengubah password user yang sedang login.
     * 
     * @authenticated
     * @bodyParam old_password string required Password lama. Example: oldpassword123
     * @bodyParam new_password string required Password baru minimal 8 karakter. Example: newpassword123
     * @bodyParam new_password_confirmation string required Konfirmasi password baru. Example: newpassword123
     * 
     * @response 200 {
     *   "message": "Password changed successfully"
     * }
     * @response 400 {
     *   "message": "Old password is incorrect"
     * }
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = $request->user();

        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'message' => 'Old password is incorrect'
            ], 400);
        }

        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'message' => 'Password changed successfully'
        ]);
    }
}
