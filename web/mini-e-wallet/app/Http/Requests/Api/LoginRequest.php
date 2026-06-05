<?php

namespace App\Http\Requests\Api;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\ValidationException;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Format email tidak valid.',
            'password.required' => 'Password wajib diisi.',
        ];
    }

    /**
     * @throws ValidationException
     */
    public function authenticate(): User
    {
        $user = User::query()
            ->where('email', $this->string('email')->value())
            ->first();

        if (! $user instanceof User) {
            throw ValidationException::withMessages([
                'email' => __('Email atau password tidak valid.'),
            ]);
        }

        return $user;
    }
}
