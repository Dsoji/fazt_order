# Mobile Auth Integration (OTP + Password)

This document describes the updated auth flow for mobile clients.

## Overview

- New users can sign up **without password**.
- Login supports **either password or email OTP code**.
- OTPs are stored in a temporary OTP collection keyed by `email + purpose`.
- For now (testing), OTP generation is hardcoded in backend config (`654321`).

## Endpoint Summary

- `POST /v1/auth/send-email-otp`
- `POST /v1/auth/verify-email-otp`
- `POST /v1/auth/signup`
- `POST /v1/auth/login`

---

## 1) Send OTP

`POST /v1/auth/send-email-otp`

Use this for both signup and login.

### Request

```json
{
  "email": "user@example.com",
  "purpose": "signup"
}
```

`purpose` must be one of:
- `signup`
- `login`

### Success response

```json
{
  "status": true,
  "message": "OTP sent successfully",
  "data": {
    "email": "user@example.com",
    "purpose": "signup",
    "expiresInMinutes": 10
  }
}
```

---

## 2) Verify OTP (for signup pre-verification)

`POST /v1/auth/verify-email-otp`

Use this before signup to verify ownership of email.

### Request

```json
{
  "email": "user@example.com",
  "otp": "654321",
  "purpose": "signup"
}
```

### Success response

```json
{
  "status": true,
  "message": "OTP verified successfully",
  "data": {
    "email": "user@example.com",
    "purpose": "signup",
    "otpProofToken": "<jwt-proof-token>"
  }
}
```

### Mobile behavior

- Use `data.email` to autofill signup email field.
- Keep email field read-only on signup screen.
- Store `otpProofToken` temporarily and pass it to signup request.

---

## 3) Signup without password

`POST /v1/auth/signup`

### Request (password optional, signupOtpToken optional)

```json
{
  "email": "user@example.com",
  "signupOtpToken": "<jwt-proof-token>",
  "firstName": "Jane",
  "lastName": "Doe",
  "phone": "08012345678",
  "password": "OptionalStrongPassword1!"
}
```

`password` is optional.  
`signupOtpToken` is optional.

### Signup modes

- **OTP-preverified signup:** include `signupOtpToken` from `/verify-email-otp` (`purpose: "signup"`).  
  User is created as verified immediately.
- **Classic signup:** no `signupOtpToken`.  
  User can still sign up normally (with password), and backend sends verification OTP like the legacy flow.

### Success response

```json
{
  "status": true,
  "message": "User Registered Successfully",
  "data": {
    "accessToken": "<access-token>",
    "refreshToken": "<refresh-token>",
    "role": "user"
  }
}
```

### Notes

- JWT tokens are issued immediately after signup in both modes.

---

## 4) Login with password OR OTP code

`POST /v1/auth/login`

### A. Password login request

```json
{
  "email": "user@example.com",
  "password": "UserPassword1!"
}
```

### B. OTP code login request

```json
{
  "email": "user@example.com",
  "code": "654321"
}
```

Rules:
- Send **either** `password` **or** `code`.
- Do not send both.

### Success response (both modes)

```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "user": {},
    "accessToken": "<access-token>",
    "refreshToken": "<refresh-token>"
  }
}
```

### OTP login sequence on mobile

1. Call `send-email-otp` with `purpose: "login"`.
2. User enters code on login screen.
3. Call `/auth/login` with `email + code`.

On successful code login, backend also sets `user.verified = true` if not already verified.

---

## Error Handling Notes

- Invalid OTP returns: `Invalid or expired OTP`.
- Wrong password returns: `Invalid email or password`.
- Sending both `password` and `code` returns validation error.
- Signup without valid `signupOtpToken` returns: `Invalid or expired OTP proof token`.

---

## Security/Testing Note

- OTP is intentionally hardcoded for now for testing.
- Before production rollout, replace hardcoded OTP with random OTP generation.
