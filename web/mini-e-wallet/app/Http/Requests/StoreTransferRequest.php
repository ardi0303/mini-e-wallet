<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreTransferRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            'recipient_user_id' => [
                'required',
                'integer',
                Rule::exists('users', 'id'),
            ],
            'amount' => [
                'required',
                'integer',
                'min:1',
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'recipient_user_id.required' => 'Penerima wajib dipilih.',
            'recipient_user_id.integer' => 'Penerima tidak valid.',
            'recipient_user_id.exists' => 'Penerima tidak ditemukan.',
            'amount.required' => 'Nominal wajib diisi.',
            'amount.integer' => 'Nominal harus berupa angka bulat.',
            'amount.min' => 'Nominal transfer harus lebih besar dari nol.',
        ];
    }
}
