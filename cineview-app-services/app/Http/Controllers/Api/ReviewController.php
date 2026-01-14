<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Review;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    /**
     * Get all reviews for authenticated user
     */
    public function index()
    {
        $user = Auth::user();

        $reviews = Review::where('user_id', $user->id)
        ->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'message' => 'Reviews retrieved succesfully',
            'data' => $reviews
        ], 200);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a new review.
     */
    public function store(Request $request)
    {
        $request->validate([
            'movie_id' => ['required', 'integer'],
            'movie_title' => ['required', 'string', 'max:255'],
            'rating' => ['required', 'integer', 'min:1', 'max:10'],
            'context' => ['required', 'string', 'max:100'],
            'content' => ['required', 'string'],
            'photo_path' => ['nullable', 'string']
        ],);

        $user = Auth::user();

        // Check if user already reviewed this movie
        $exists = Review::where('user_id', $user->id)
        ->where('movie_id', $request->movie_id)->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'You have already reviewed this movie'
            ], 409);
        }

        $review = Review::create([
            'user_id' => $user->id,
            'movie_id' => $request->movie_id,
            'movie_title' => $request->movie_title,
            'rating' => $request->rating,
            'context' => $request->context,
            'content' => $request->content,
            'photo_path' => $request->photo_path
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Review created successfully',
            'data' => $review
        ], 201);
    }

    /**
     * Get a specific review
     */
    public function show(string $id)
    {
        $user = Auth::user();

        $review = Review::where('id', $id)
        ->where('user_id', $user->id)
        ->first();

        if (!$review) {
            return response()->json([
                'success' => false,
                'message' => 'Review not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $review
        ], 200);
    }

    /**
     * Update a review
     */
    public function update(Request $request, string $id)
    {
        $request->validate([
            'rating' => ['sometimes', 'integer', 'min:1', 'max:10'],
            'context' => ['sometimes', 'string', 'max:100'],
            'content' => ['sometimes', 'string'],
            'photo_path' => ['nullable', 'string']
        ], 404);

        $user = Auth::user();

        $review = Review::where('id', $id)
        ->where('user_id', $user->id)->first();

        if (!$review){
            return response()->json([
                'success' => false,
                'message' => 'Review not found'
            ], 404);
        }

        $review->update($request->only(['rating', 'context', 'content', 'photo_path']));

        return response()->json([
            'success' => true,
            'message' => 'Review updated successfully',
            'data' => $review
        ], 200);
    }

    /**
     * Delete a review
     */
    public function destroy(string $id)
    {
        $user = Auth::user();

        $review = Review::where('id', $id)
        ->where('user_id', $user->id)->first();

        if (!$review){
            return response()->json([
                'success' => false,
                'message' => 'Review not found'
            ], 404);
        }

        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review deleted successfully'
        ], 200);
    }

    /**
     * Get all reviews for a specific movie (from all users)
     * 
     * @unauthenticated
     * 
     * @response 200{
     * 
     * }    
     */
    public function getByMovie(string $movie_id){
        $reviews = Review::where('movie_id', $movie_id)
        ->with('user:id,name,profile_photo') 
        -> orderBy('created_at', 'desc') -> get();
        
        $averageRating = $reviews->avg('rating');
        $totalReviews = $reviews->count();

        return response()->json([
            'success' => true,
            'message' => 'Reviews retrieved successfully',
            'averageRating' => round($averageRating, 1),
            'totalReviews' => $totalReviews,
            'data' => $reviews
        ], 200);
    }
}
