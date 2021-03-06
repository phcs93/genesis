// original -> http://staffwww.itn.liu.se/~stegu/aqsis/aqsis-newnoise/sdnoise1234.c

const noiseSource = `

	uniform sampler2D permutation;
	uniform sampler2D simplex;
	uniform sampler2D tesseract;


// vec4[32] grad4lut = vec4[32](
//     vec4( 0.0, 1.0, 1.0, 1.0 ), vec4( 0.0, 1.0, 1.0, -1.0 ), vec4( 0.0, 1.0, -1.0, 1.0 ), vec4( 0.0, 1.0, -1.0, -1.0 ), // 32 tesseract edges
//     vec4( 0.0, -1.0, 1.0, 1.0 ), vec4( 0.0, -1.0, 1.0, -1.0 ), vec4( 0.0, -1.0, -1.0, 1.0 ), vec4( 0.0, -1.0, -1.0, -1.0 ),
//     vec4( 1.0, 0.0, 1.0, 1.0 ), vec4( 1.0, 0.0, 1.0, -1.0 ), vec4( 1.0, 0.0, -1.0, 1.0 ), vec4( 1.0, 0.0, -1.0, -1.0 ),
//     vec4( -1.0, 0.0, 1.0, 1.0 ), vec4( -1.0, 0.0, 1.0, -1.0 ), vec4( -1.0, 0.0, -1.0, 1.0 ), vec4( -1.0, 0.0, -1.0, -1.0 ),
//     vec4( 1.0, 1.0, 0.0, 1.0 ), vec4( 1.0, 1.0, 0.0, -1.0 ), vec4( 1.0, -1.0, 0.0, 1.0 ), vec4( 1.0, -1.0, 0.0, -1.0 ),
//     vec4( -1.0, 1.0, 0.0, 1.0 ), vec4( -1.0, 1.0, 0.0, -1.0 ), vec4( -1.0, -1.0, 0.0, 1.0 ), vec4( -1.0, -1.0, 0.0, -1.0 ),
//     vec4( 1.0, 1.0, 1.0, 0.0 ), vec4( 1.0, 1.0, -1.0, 0.0 ), vec4( 1.0, -1.0, 1.0, 0.0 ), vec4( 1.0, -1.0, -1.0, 0.0 ),
//     vec4( -1.0, 1.0, 1.0, 0.0 ), vec4( -1.0, 1.0, -1.0, 0.0 ), vec4( -1.0, -1.0, 1.0, 0.0 ), vec4( -1.0, -1.0, -1.0, 0.0)
// );

// ivec4[64] simplex = ivec4[64](
//     ivec4(0,1,2,3),ivec4(0,1,3,2),ivec4(0,0,0,0),ivec4(0,2,3,1),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(1,2,3,0),
//     ivec4(0,2,1,3),ivec4(0,0,0,0),ivec4(0,3,1,2),ivec4(0,3,2,1),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(1,3,2,0),
//     ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),
//     ivec4(1,2,0,3),ivec4(0,0,0,0),ivec4(1,3,0,2),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(2,3,0,1),ivec4(2,3,1,0),
//     ivec4(1,0,2,3),ivec4(1,0,3,2),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(2,0,3,1),ivec4(0,0,0,0),ivec4(2,1,3,0),
//     ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),
//     ivec4(2,0,1,3),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(3,0,1,2),ivec4(3,0,2,1),ivec4(0,0,0,0),ivec4(3,1,2,0),
//     ivec4(2,1,0,3),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(0,0,0,0),ivec4(3,1,0,2),ivec4(0,0,0,0),ivec4(3,2,0,1),ivec4(3,2,1,0)
// );

	int perm (int i) {
		vec2 p = vec2(float(i)/512.0, 0.0);
		return int(texture(permutation, p).a * 255.0);
	}

	// ivec4 simp (int i) {
	// 	vec2 p = vec2(float(i)/64.0, 0.0);
	// 	return ivec4(texture(simplex, p) * 255.0 );
	// }

	ivec4 simp (int i) {
		vec2 p = vec2(float(i)/64.0, 0.0);
		return ivec4(floor(texture(simplex, p) * 255.0));
	}

	vec4 tess (int i) {
		vec2 p = vec2(float(i)/32.0, 0.0);
		return texture(tesseract, p) / 0.5 - 0.5;
	}

	// ivec4 simp (int i) {
	// 	return simplex[i];
	// }

	// vec4 tess (int i) {
	// 	return grad4lut[i];
	// }

	void grad (int hash, out float gx, out float gy, out float gz, out float gw) {
		int h = hash & 31;
		gx = tess(h)[0];
		gy = tess(h)[1];
		gz = tess(h)[2];
		gw = tess(h)[3];
	}

	const float F4 = 0.309016994;
	const float G4 = 0.138196601;

	float noise (float x, float y, float z, float w, out float dnoise_dx, out float dnoise_dy, out float dnoise_dz, out float dnoise_dw) {

		float n0, n1, n2, n3, n4;
		float gx0, gy0, gz0, gw0, gx1, gy1, gz1, gw1;
		float gx2, gy2, gz2, gw2, gx3, gy3, gz3, gw3, gx4, gy4, gz4, gw4;
		float t20, t21, t22, t23, t24;
		float t40, t41, t42, t43, t44;

		float s = (x + y + z + w) * F4; 
		float xs = x + s;
		float ys = y + s;
		float zs = z + s;
		float ws = w + s;
		int i = int(floor(xs));
		int j = int(floor(ys));
		int k = int(floor(zs));
		int l = int(floor(ws));

		float t = float(i + j + k + l) * G4; 
		float X0 = float(i) - t; 
		float Y0 = float(j) - t;
		float Z0 = float(k) - t;
		float W0 = float(l) - t;

		float x0 = x - X0;  
		float y0 = y - Y0;
		float z0 = z - Z0;
		float w0 = w - W0;

		int c1 = (x0 > y0) ? 32 : 0;
		int c2 = (x0 > z0) ? 16 : 0;
		int c3 = (y0 > z0) ? 8 : 0;
		int c4 = (x0 > w0) ? 4 : 0;
		int c5 = (y0 > w0) ? 2 : 0;
		int c6 = (z0 > w0) ? 1 : 0;
		int c = c1 | c2 | c3 | c4 | c5 | c6; 

		int i1 = simp(c)[0] >= 30 ? 1 : 0;
		int j1 = simp(c)[1] >= 30 ? 1 : 0;
		int k1 = simp(c)[2] >= 30 ? 1 : 0;
		int l1 = simp(c)[3] >= 30 ? 1 : 0;
		int i2 = simp(c)[0] >= 20 ? 1 : 0;
		int j2 = simp(c)[1] >= 20 ? 1 : 0;
		int k2 = simp(c)[2] >= 20 ? 1 : 0;
		int l2 = simp(c)[3] >= 20 ? 1 : 0;
		int i3 = simp(c)[0] >= 10 ? 1 : 0;
		int j3 = simp(c)[1] >= 10 ? 1 : 0;
		int k3 = simp(c)[2] >= 10 ? 1 : 0;
		int l3 = simp(c)[3] >= 10 ? 1 : 0;

		float x1 = x0 - float(i1) + G4; 
		float y1 = y0 - float(j1) + G4;
		float z1 = z0 - float(k1) + G4;
		float w1 = w0 - float(l1) + G4;
		float x2 = x0 - float(i2) + 2.0 * G4; 
		float y2 = y0 - float(j2) + 2.0 * G4;
		float z2 = z0 - float(k2) + 2.0 * G4;
		float w2 = w0 - float(l2) + 2.0 * G4;
		float x3 = x0 - float(i3) + 3.0 * G4; 
		float y3 = y0 - float(j3) + 3.0 * G4;
		float z3 = z0 - float(k3) + 3.0 * G4;
		float w3 = w0 - float(l3) + 3.0 * G4;
		float x4 = x0 - 1.0 + 4.0 * G4; 
		float y4 = y0 - 1.0 + 4.0 * G4;
		float z4 = z0 - 1.0 + 4.0 * G4;
		float w4 = w0 - 1.0 + 4.0 * G4;

		int ii = i & 0xff;
		int jj = j & 0xff;
		int kk = k & 0xff;
		int ll = l & 0xff;

		float t0 = 0.6 - x0*x0 - y0*y0 - z0*z0 - w0*w0;
		float t1 = 0.6 - x1*x1 - y1*y1 - z1*z1 - w1*w1;
		float t2 = 0.6 - x2*x2 - y2*y2 - z2*z2 - w2*w2;
		float t3 = 0.6 - x3*x3 - y3*y3 - z3*z3 - w3*w3;
		float t4 = 0.6 - x4*x4 - y4*y4 - z4*z4 - w4*w4;

		if (t0 < 0.0) { 
			n0 = t0 = t20 = t40 = gx0 = gy0 = gz0 = gw0 = 0.0;
		} else {
			t20 = t0 * t0;
			t40 = t20 * t20;
			grad(perm(ii+perm(jj+perm(kk+perm(ll)))), gx0,gy0,gz0,gw0);
			n0 = t40 * ( gx0 * x0 + gy0 * y0 + gz0 * z0 + gw0 * w0 );
		}

		if (t1 < 0.0) {
			n1 = t1 = t21 = t41 = gx1 = gy1 = gz1 = gw1 = 0.0;
		} else {
			t21 = t1 * t1;
			t41 = t21 * t21;
			grad(perm(ii+i1+perm(jj+j1+perm(kk+k1+perm(ll+l1)))), gx1,gy1,gz1,gw1);
			n1 = t41 * ( gx1 * x1 + gy1 * y1 + gz1 * z1 + gw1 * w1 );
		}

		if( t2 < 0.0) {
			n2 = t2 = t22 = t42 = gx2 = gy2 = gz2 = gw2 = 0.0;
		} else {
			t22 = t2 * t2;
			t42 = t22 * t22;
			grad(perm(ii+i2+perm(jj+j2+perm(kk+k2+perm(ll+l2)))), gx2,gy2,gz2,gw2);
			n2 = t42 * ( gx2 * x2 + gy2 * y2 + gz2 * z2 + gw2 * w2 );
		}

		if (t3 < 0.0) {
			n3 = t3 = t23 = t43 = gx3 = gy3 = gz3 = gw3 = 0.0;
		} else {
			t23 = t3 * t3;
			t43 = t23 * t23;
			grad(perm(ii+i3+perm(jj+j3+perm(kk+k3+perm(ll+l3)))), gx3,gy3,gz3,gw3);
			n3 = t43 * ( gx3 * x3 + gy3 * y3 + gz3 * z3 + gw3 * w3 );
		}

		if (t4 < 0.0) {
			n4 = t4 = t24 = t44 = gx4 = gy4 = gz4 = gw4 = 0.0;
		} else {
			t24 = t4 * t4;
			t44 = t24 * t24;
			grad(perm(ii+1+perm(jj+1+perm(kk+1+perm(ll+1)))), gx4,gy4,gz4,gw4);
			n4 = t44 * ( gx4 * x4 + gy4 * y4 + gz4 * z4 + gw4 * w4 );
		}

		float temp0 = t20 * t0 * ( gx0 * x0 + gy0 * y0 + gz0 * z0 + gw0 * w0 );
		dnoise_dx = temp0 * x0;
		dnoise_dy = temp0 * y0;
		dnoise_dz = temp0 * z0;
		dnoise_dw = temp0 * w0;
		float temp1 = t21 * t1 * ( gx1 * x1 + gy1 * y1 + gz1 * z1 + gw1 * w1 );
		dnoise_dx += temp1 * x1;
		dnoise_dy += temp1 * y1;
		dnoise_dz += temp1 * z1;
		dnoise_dw += temp1 * w1;
		float temp2 = t22 * t2 * ( gx2 * x2 + gy2 * y2 + gz2 * z2 + gw2 * w2 );
		dnoise_dx += temp2 * x2;
		dnoise_dy += temp2 * y2;
		dnoise_dz += temp2 * z2;
		dnoise_dw += temp2 * w2;
		float temp3 = t23 * t3 * ( gx3 * x3 + gy3 * y3 + gz3 * z3 + gw3 * w3 );
		dnoise_dx += temp3 * x3;
		dnoise_dy += temp3 * y3;
		dnoise_dz += temp3 * z3;
		dnoise_dw += temp3 * w3;
		float temp4 = t24 * t4 * ( gx4 * x4 + gy4 * y4 + gz4 * z4 + gw4 * w4 );
		dnoise_dx += temp4 * x4;
		dnoise_dy += temp4 * y4;
		dnoise_dz += temp4 * z4;
		dnoise_dw += temp4 * w4;
		dnoise_dx *= -8.0;
		dnoise_dy *= -8.0;
		dnoise_dz *= -8.0;
		dnoise_dw *= -8.0;
		dnoise_dx += t40 * gx0 + t41 * gx1 + t42 * gx2 + t43 * gx3 + t44 * gx4;
		dnoise_dy += t40 * gy0 + t41 * gy1 + t42 * gy2 + t43 * gy3 + t44 * gy4;
		dnoise_dz += t40 * gz0 + t41 * gz1 + t42 * gz2 + t43 * gz3 + t44 * gz4;
		dnoise_dw += t40 * gw0 + t41 * gw1 + t42 * gw2 + t43 * gw3 + t44 * gw4;
		dnoise_dx *= 28.0; 
		dnoise_dy *= 28.0;
		dnoise_dz *= 28.0;
		dnoise_dw *= 28.0;
		dnoise_dx *= 0.5; 
		dnoise_dy *= 0.5;
		dnoise_dz *= 0.5;
		dnoise_dw *= 0.5;
		dnoise_dx += 0.5; 
		dnoise_dy += 0.5;
		dnoise_dz += 0.5;
		dnoise_dw += 0.5;

		dnoise_dx = clamp(dnoise_dx, 0.0, 1.0); 
		dnoise_dy = clamp(dnoise_dy, 0.0, 1.0);
		dnoise_dz = clamp(dnoise_dz, 0.0, 1.0);
		dnoise_dw = clamp(dnoise_dw, 0.0, 1.0);

		return (27.0 * (n0 + n1 + n2 + n3 + n4)) * 0.5 + 0.5;

	}

`;