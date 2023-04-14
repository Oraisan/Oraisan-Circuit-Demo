import hashlib

def sha512(s):
    return hashlib.sha512(s).digest()

# Base field Z_p
p = 2**255 - 19

def modp_inv(x):
    return pow(x, p-2, p)

# Curve constant
d = -121665 * modp_inv(121666) % p

# Group order
q = 2**252 + 27742317777372353535851937790883648493

def sha512_modq(s):
    return int.from_bytes(sha512(s), "little") % q

## Then follows functions to perform point operations.

# Points are represented as tuples (X, Y, Z, T) of extended
# coordinates, with x = X/Z, y = Y/Z, x*y = T/Z

def point_add(P, Q):
    A, B = (P[1]-P[0]) * (Q[1]-Q[0]) % p, (P[1]+P[0]) * (Q[1]+Q[0]) % p
    C, D = 2 * P[3] * Q[3] * d % p, 2 * P[2] * Q[2] % p
    E, F, G, H = B-A, D-C, D+C, B+A
    return (E*F, G*H, F*G, E*H)

# Computes Q = s * Q
def point_mul(s, P):
    Q = (0, 1, 1, 0)  # Neutral element
    while s > 0:
        if s & 1:
            Q = point_add(Q, P)
        P = point_add(P, P)
        s >>= 1
    return Q

def point_equal(P, Q):
    # x1 / z1 == x2 / z2  <==>  x1 * z2 == x2 * z1
    if (P[0] * Q[2] - Q[0] * P[2]) % p != 0:
        return False
    if (P[1] * Q[2] - Q[1] * P[2]) % p != 0:
        return False
    return True

## Now follows functions for point compression.

# Square root of -1
modp_sqrt_m1 = pow(2, (p-1) // 4, p)

# Compute corresponding x-coordinate, with low bit corresponding to
# sign, or return None on failure
def recover_x(y, sign):
    if y >= p:
        return None
    x2 = (y*y-1) * modp_inv(d*y*y+1)
    if x2 == 0:
        if sign:
            return None
        else:
            return 0

    # Compute square root of x2
    x = pow(x2, (p+3) // 8, p)
    print("x", x)
    if (x*x - x2) % p != 0:
        x = x * modp_sqrt_m1 % p
        # print("x1", x)
    if (x*x - x2) % p != 0:
        return None

    if (x & 1) != sign:
        x = p - x
        # print("x2", x)
    return x

g_y = 4 * modp_inv(5) % p
g_x = recover_x(g_y, 0)
G = (g_x, g_y, 1, g_x * g_y % p)

def point_compress(P):
    zinv = modp_inv(P[2])
    x = P[0] * zinv % p
    y = P[1] * zinv % p
    return int.to_bytes(y | ((x & 1) << 255), 32, "little")

def point_decompress(s):
    if len(s) != 32:
        raise Exception("Invalid input length for decompression")
    y = int.from_bytes(s, "little")
    sign = y >> 255
    y &= (1 << 255) - 1

    print("y", y)
    print("sign", sign)
    x = recover_x(y, sign)
    if x is None:
        return None
    else:
        return (x, y, 1, x*y % p)

## These are functions for manipulating the private key.

def secret_expand(secret):
    if len(secret) != 32:
        raise Exception("Bad size of private key")
    h = sha512(secret)
    a = int.from_bytes(h[:32], "little")
    a &= (1 << 254) - 8
    a |= (1 << 254)
    return (a, h[32:])

def secret_to_public(secret):
    (a, dummy) = secret_expand(secret)
    return point_compress(point_mul(a, G))

## The signature function works as below.

def sign(secret, msg):
    a, prefix = secret_expand(secret)
    A = point_compress(point_mul(a, G))
    r = sha512_modq(prefix + msg)
    R = point_mul(r, G)
    Rs = point_compress(R)
    h = sha512_modq(Rs + A + msg)
    s = (r + h * a) % q
    # print("pubKey", A.hex())
    # print(verify(A, msg, Rs + int.to_bytes(s, 32, "little")))
    return Rs + int.to_bytes(s, 32, "little")

## And finally the verification function.

def verify(public, msg, signature):
    if len(public) != 32:
        raise Exception("Bad public key length")
    if len(signature) != 64:
        Exception("Bad signature length")
    A = point_decompress(public)
    if not A:
        return False
    Rs = signature[:32]
    R = point_decompress(Rs)
    if not R:
        return False
    # A = (19609600535639426967582330360073854330664420980290928614443703354937550235772, 4819101209465356224883271557990864103528016550052741516590013689083114432765, 1, 51169037833951159944323311113976941583233159633603343645972292487679672161224)
    # R = (37880392645989658068752609291251083631204709745327980624473693943571704213899, 4441405635204378107364157117381717143569046592695380934007350497764283041565, 1, 29423111549617446375779108146631000784035658644093037228114776583127667239194)
    s = int.from_bytes(signature[32:], "little")
    # print("A", type(A))
    # print("R", Rs)
    # print(Rs.hex())
    # print(signature[32:].hex())
    if s >= q: return False
    h = sha512_modq(Rs + public + msg)
    sB = point_mul(s, G)
    hA = point_mul(h, A)
    return point_equal(sB, point_add(R, hA))
# secret = ("00000000000000000000000000000000").encode()
# public = [61, 64, 23, 195, 232, 67, 137, 90, 146, 183, 10, 167, 77, 27, 126, 188, 156, 152, 44, 207, 46, 196, 150, 140, 192, 205, 85, 241, 42, 244, 102, 12]
# msg = ("200").encode()

# print(msg.hex())
# # b = bytes.fromhex("82AF")
# print(type(msg))
pubKeys = bytes.fromhex("FD284E309E23A18641A8F545B43D3EB24539F65061F38B80C8B92678BE83A70A")
# pubKeys = (114506364221104021127115807106445440684533277565203929892187927450183962699530).to_bytes(32, "little")
# msg = bytes([110, 8, 2, 17, 197, 198, 157, 0, 0, 0, 0, 0, 34, 72, 10, 32, 221, 176, 16, 254, 205, 166, 67, 239, 182, 231, 240, 251, 203, 176, 164, 171, 127, 35, 23, 63, 134, 91, 64, 237, 244, 113, 57, 163, 98, 126, 18, 0, 18, 36, 8, 1, 18, 32, 28, 66, 108, 220, 131, 113, 179, 106, 254, 145, 161, 129, 136, 18, 8, 121, 3, 179, 92, 111, 198, 239, 153, 141, 25, 255, 45, 207, 110, 250, 0, 165, 42, 12, 8, 228, 139, 196, 159, 6, 16, 179, 137, 182, 245, 1, 50, 9, 79, 114, 97, 105, 99, 104, 97, 105, 110])
msg = bytes.fromhex("6e080211c5c69d000000000022480a20ddb010fecda643efb6e7f0fbcbb0a4ab7f23173f865b40edf47139a3627e12001224080112201c426cdc8371b36afe91a1818812087903b35c6fc6ef998d19ff2dcf6efa00a52a0c08e48bc49f0610b389b6f50132094f726169636861696e")
R8 = bytes([29, 199, 36, 178, 84, 166, 115, 76, 30, 71, 15, 32, 51, 147, 51, 1, 30, 66, 149, 118, 179, 245, 1, 108, 92, 133, 123, 255, 26, 191, 209, 137])
S = bytes([204, 46, 245, 69, 46, 84, 169, 94, 155, 240, 248, 97, 172, 191, 212, 248, 191, 204, 117, 38, 12, 181, 189, 199, 208, 109, 101, 68, 129, 167, 97, 4])
# signatures = bytes([29, 199, 36, 178, 84, 166, 115, 76, 30, 71, 15, 32, 51, 147, 51, 1, 30, 66, 149, 118, 179, 245, 1, 108, 92, 133, 123, 255, 26, 191, 209, 137, 204, 46, 245, 69, 46, 84, 169, 94, 155, 240, 248, 97, 172, 191, 212, 248, 191, 204, 117, 38, 12, 181, 189, 199, 208, 109, 101, 68, 129, 167, 97, 4])
signatures = bytes.fromhex("1dc724b254a6734c1e470f20339333011e429576b3f5016c5c857bff1abfd189cc2ef5452e54a95e9bf0f861acbfd4f8bfcc75260cb5bdc7d06d654481a76104")
# print("xyz", (92354788868936625807699115826764918510763644220227890190145006419348403216644).to_bytes(32, "little").hex())
# print(R8.hex())
# print(S.hex())

# print(pubKeys.hex())
# verify(pubKeys, msg, signatures)
# print(sign(secret, msg).hex())

# signature = [146, 160, 9, 169, 240, 212, 202, 184, 114, 14, 130, 11, 95, 100, 37, 64, 162, 178, 123, 84, 22, 80, 63, 143, 179, 118, 34, 35, 235, 219, 105, 218, 8, 90, 193, 228, 62, 21, 153, 110, 69, 143, 54, 19, 208, 241, 29, 140, 56, 123, 46, 174, 180, 48, 42, 238, 176, 13, 41, 22, 18, 187, 12, 0]

# verify(public, msg, signature)
point_decompress(pubKeys)