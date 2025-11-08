<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class TransactionController extends Controller
{
    // Get all transactions
    public function index(Request $request)
    {
        try {
            $query = Transaction::with('category')
                ->where('user_id', $request->user()->id);

            // Filter by type
            if ($request->has('type')) {
                $query->where('type', $request->type);
            }

            // Filter by category
            if ($request->has('category_id')) {
                $query->where('category_id', $request->category_id);
            }

            // Filter by date range
            if ($request->has('start_date')) {
                $query->whereDate('date', '>=', $request->start_date);
            }
            if ($request->has('end_date')) {
                $query->whereDate('date', '<=', $request->end_date);
            }

            // Filter by month & year
            if ($request->has('month') && $request->has('year')) {
                $query->whereMonth('date', $request->month)
                      ->whereYear('date', $request->year);
            }

            $transactions = $query->orderBy('date', 'desc')->get();

            return response()->json([
                'success' => true,
                'data' => $transactions
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get transactions: ' . $e->getMessage()
            ], 500);
        }
    }

    // Create transaction
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'category_id' => 'required|exists:categories,id',
                'amount' => 'required|numeric|min:0',
                'type' => 'required|in:income,expense',
                'description' => 'nullable|string',
                'date' => 'required|date',
            ]);

            // Cek apakah kategori milik user yang login
            $category = \App\Models\Category::where('id', $validated['category_id'])
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$category) {
                return response()->json([
                    'success' => false,
                    'message' => 'Category not found or not belongs to you'
                ], 403);
            }

            $transaction = Transaction::create([
                'user_id' => $request->user()->id,
                'category_id' => $validated['category_id'],
                'amount' => $validated['amount'],
                'type' => $validated['type'],
                'description' => $validated['description'],
                'date' => $validated['date'],
            ]);

            // ==== Tambahan logic update budget ====
            if ($validated['type'] === 'expense') {
                $budget = \App\Models\Budget::where('category_id', $validated['category_id'])
                    ->where('user_id', $request->user()->id)
                    ->first();

                if ($budget) {
                    // Misal kolom di tabel budgets namanya 'used' buat nampung total pengeluaran
                    $budget->used = $budget->used + $validated['amount'];
                    $budget->save();
                }
            }
            // =======================================

            $transaction->load('category');

            return response()->json([
                'success' => true,
                'message' => 'Transaction created successfully',
                'data' => $transaction
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create transaction: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get single transaction
    public function show(Request $request, $id)
    {
        try {
            $transaction = Transaction::with('category')
                ->where('user_id', $request->user()->id)
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $transaction
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Transaction not found'
            ], 404);
        }
    }

    // Update transaction
    public function update(Request $request, $id)
    {
        try {
            $transaction = Transaction::where('user_id', $request->user()->id)
                ->findOrFail($id);

            $validated = $request->validate([
                'category_id' => 'sometimes|exists:categories,id',
                'amount' => 'sometimes|numeric|min:0',
                'type' => 'sometimes|in:income,expense',
                'description' => 'nullable|string',
                'date' => 'sometimes|date',
            ]);

            $transaction->update($validated);
            $transaction->load('category');

            return response()->json([
                'success' => true,
                'message' => 'Transaction updated successfully',
                'data' => $transaction
            ], 200);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update transaction: ' . $e->getMessage()
            ], 500);
        }
    }

    // Delete transaction
    public function destroy(Request $request, $id)
    {
        try {
            $transaction = Transaction::where('user_id', $request->user()->id)
                ->findOrFail($id);

            $transaction->delete();

            return response()->json([
                'success' => true,
                'message' => 'Transaction deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete transaction: ' . $e->getMessage()
            ], 500);
        }
    }
}