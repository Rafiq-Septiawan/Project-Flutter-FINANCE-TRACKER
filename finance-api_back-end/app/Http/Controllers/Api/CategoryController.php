<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // Get all categories
    public function index(Request $request)
    {
        $type = $request->query('type'); // income or expense
        
        $query = Category::where('user_id', $request->user()->id);
        
        if ($type) {
            $query->where('type', $type);
        }
        
        $categories = $query->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    // Create category
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:income,expense',
            'icon' => 'nullable|string',
            'color' => 'nullable|string',
        ]);

        $category = Category::create([
            'user_id' => $request->user()->id,
            'name' => $request->name,
            'type' => $request->type,
            'icon' => $request->icon,
            'color' => $request->color,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Category created successfully',
            'data' => $category
        ], 201);
    }

    // Get single category
    public function show(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $category
        ]);
    }

    // Update category
    public function update(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'type' => 'sometimes|in:income,expense',
            'icon' => 'nullable|string',
            'color' => 'nullable|string',
        ]);

        $category->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Category updated successfully',
            'data' => $category
        ]);
    }

    // Delete category
    public function destroy(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted successfully'
        ]);
    }
}