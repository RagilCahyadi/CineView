<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Watchlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WatchlistController extends Controller
{
    /**
     * Get all watchlist items for authenticated user
     */
    public function index()
    {
        $user = Auth::user();
        $watchlist = Watchlist::where('user_id', $user->id)
        ->orderBy('added_at','desc')->get();

        return response()->json([
            'success' => true,
            'message' => 'Watchlist retrieved successfully',
            'data' => $watchlist
        ], 200);
    }

    /**
     * Add a movie to watchlist
     */
    public function store(Request $request)
    {
        $request->validate([
            'movie_id' => ['required', 'integer'],
            'movie_title' => ['required', 'string', 'max:255'],
            'poster_path' => ['nullable', 'string']     
        ]);

        $user = Auth::user();

        // Check if movie already in watchlist
        $exist = Watchlist::where('user_id', $user->id)
        ->where('movie_id', $request->movie_id)->exists();

        if ($exist) {
            return response()->json([
                'success' => false,
                'message' => 'Movie already in watchlist',
            ], 409);
        }

        $watchlist = Watchlist::create([
            'user_id' => $user->id,
            'movie_id' => $request->movie_id,
            'movie_title' => $request->movie_title,
            'poster_path' => $request->poster_path,
            'added_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Movie added to watchlist',
            'data' => $watchlist
        ], 201); 
    }

    /**
     * Remove a movie from watchlist
     */
    public function destroy(string $id)
    {
        $user = Auth::user();
        $watchlist = Watchlist::where('id', $id)
        ->where('user_id', $user->id)->first();

        if(!$watchlist){
            return response()->json([
                'success' => false,
                'message' => 'Watchlist item not found'
            ], 404);
        }

        $watchlist->delete();

        return response()->json([
            'success' => true,
            'message' => 'Movie removed from watchlist'
        ], 200);
    }

    /**
     * Get all movies in watchlist for authenticated user
     */
    public function check(string $movie_id)
    {
       $user = Auth::user();

       $exist = Watchlist::where('user_id', $user->id)
       ->where('movie_id', $movie_id)->exists();

       return response()->json([
            'success' => true,
            'in_watchlist' => $exist
       ], 200);
    }
}
