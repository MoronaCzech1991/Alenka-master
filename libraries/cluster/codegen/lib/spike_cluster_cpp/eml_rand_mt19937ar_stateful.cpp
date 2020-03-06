
// Include Files
#include "eml_rand_mt19937ar_stateful.h"
#include "rt_nonfinite.h"
#include "spike_cluster_cpp.h"
#include "spike_cluster_cpp_emxutil.h"

// Variable Definitions
static unsigned int state[625];

#pragma omp threadprivate(state)

static boolean_T state_not_empty = false;

#pragma omp threadprivate(state_not_empty)

static unsigned int state_master[625];
static unsigned int (*state_ptr)[625];

#pragma omp threadprivate(state_ptr)

static boolean_T state_not_empty_master = false;

// Function Declarations
static double b_eml_rand_mt19937ar(unsigned int b_state[625]);
static void eml_rand_mt19937ar(unsigned int b_state[625]);

// Function Definitions

//
// Arguments    : unsigned int b_state[625]
// Return Type  : double
//
static double b_eml_rand_mt19937ar(unsigned int b_state[625]) {
  double r;
  int exitg1;
  unsigned int u[2];
  int k;
  unsigned int b_r;
  int kk;
  boolean_T isvalid;
  unsigned int y;
  unsigned int b_y;
  boolean_T exitg2;
  unsigned int c_y;
  unsigned int d_y;

  // ========================= COPYRIGHT NOTICE ============================
  //  This is a uniform (0,1) pseudorandom number generator based on:
  //
  //  A C-program for MT19937, with initialization improved 2002/1/26.
  //  Coded by Takuji Nishimura and Makoto Matsumoto.
  //
  //  Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
  //  All rights reserved.
  //
  //  Redistribution and use in source and binary forms, with or without
  //  modification, are permitted provided that the following conditions
  //  are met:
  //
  //    1. Redistributions of source code must retain the above copyright
  //       notice, this list of conditions and the following disclaimer.
  //
  //    2. Redistributions in binary form must reproduce the above copyright
  //       notice, this list of conditions and the following disclaimer
  //       in the documentation and/or other materials provided with the
  //       distribution.
  //
  //    3. The names of its contributors may not be used to endorse or
  //       promote products derived from this software without specific
  //       prior written permission.
  //
  //  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  //  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  //  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  //  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
  //  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  //  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  //  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  //  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  //  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  //  (INCLUDING  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  //  OF THIS  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  //
  // =============================   END   =================================
  do {
    exitg1 = 0;
    for (k = 0; k < 2; k++) {
      b_r = b_state[624] + 1U;
      if (b_r >= 625U) {
        for (kk = 0; kk < 227; kk++) {
          y = (b_state[kk] & 2147483648U) | (b_state[1 + kk] & 2147483647U);
          if ((int)(y & 1U) == 0) {
            b_y = y >> 1U;
          } else {
            b_y = y >> 1U ^ 2567483615U;
          }

          b_state[kk] = b_state[397 + kk] ^ b_y;
        }

        for (kk = 0; kk < 396; kk++) {
          y = (b_state[kk + 227] & 2147483648U) |
              (b_state[228 + kk] & 2147483647U);
          if ((int)(y & 1U) == 0) {
            d_y = y >> 1U;
          } else {
            d_y = y >> 1U ^ 2567483615U;
          }

          b_state[kk + 227] = b_state[kk] ^ d_y;
        }

        y = (b_state[623] & 2147483648U) | (b_state[0] & 2147483647U);
        if ((int)(y & 1U) == 0) {
          c_y = y >> 1U;
        } else {
          c_y = y >> 1U ^ 2567483615U;
        }

        b_state[623] = b_state[396] ^ c_y;
        b_r = 1U;
      }

      y = b_state[(int)b_r - 1];
      b_state[624] = b_r;
      y ^= y >> 11U;
      y ^= y << 7U & 2636928640U;
      y ^= y << 15U & 4022730752U;
      y ^= y >> 18U;
      u[k] = y;
    }

    r = 1.1102230246251565E-16 *
        ((double)(u[0] >> 5U) * 6.7108864E+7 + (double)(u[1] >> 6U));
    if (r == 0.0) {
      if ((b_state[624] >= 1U) && (b_state[624] < 625U)) {
        isvalid = true;
      } else {
        isvalid = false;
      }

      if (isvalid) {
        isvalid = false;
        k = 1;
        exitg2 = false;
        while ((!exitg2) && (k < 625)) {
          if (b_state[k - 1] == 0U) {
            k++;
          } else {
            isvalid = true;
            exitg2 = true;
          }
        }
      }

      if (!isvalid) {
        b_r = 5489U;
        b_state[0] = 5489U;
        for (k = 0; k < 623; k++) {
          b_r = (b_r ^ b_r >> 30U) * 1812433253U + (1 + k);
          b_state[k + 1] = b_r;
        }

        b_state[624] = 624U;
      }
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  return r;
}

//
// Arguments    : unsigned int b_state[625]
// Return Type  : void
//
static void eml_rand_mt19937ar(unsigned int b_state[625]) {
  unsigned int r;
  int mti;
  if (omp_in_parallel()) {
    mti = getThreadID();
    if (mti > 2147483646) {
      mti = MAX_int32_T;
    } else {
      mti++;
    }

    if (mti < 0) {
      mti = 0;
    }

    r = (unsigned int)mti;
    b_state[0] = r;
    for (mti = 0; mti < 623; mti++) {
      r = (r ^ r >> 30U) * 1812433253U + (1 + mti);
      b_state[mti + 1] = r;
    }

    b_state[624] = 624U;
  } else {
    r = 5489U;
    b_state[0] = 5489U;
    for (mti = 0; mti < 623; mti++) {
      r = (r ^ r >> 30U) * 1812433253U + (1 + mti);
      b_state[mti + 1] = r;
    }

    b_state[624] = 624U;
  }
}

//
// Arguments    : double varargin_2
//                emxArray_real_T *r
// Return Type  : void
//
void b_eml_rand_mt19937ar_stateful(double varargin_2, emxArray_real_T *r) {
  int i3;
  int k;
  i3 = r->size[0] * r->size[1];
  r->size[0] = 1;
  r->size[1] = (int)varargin_2;
  emxEnsureCapacity((emxArray__common *)r, i3, (int)sizeof(double));
  i3 = r->size[1];
  for (k = 0; k < i3; k++) {
    r->data[k] = b_eml_rand_mt19937ar(*state_ptr);
  }
}

//
// Arguments    : void
// Return Type  : void
//
void c_eml_rand_mt19937ar_stateful_i() {
  int ub_loop;
  int i;
  unsigned int uv0[625];
  unsigned int uv1[625];
  ub_loop = omp_get_max_threads();

#pragma omp parallel for schedule(static) num_threads(omp_get_max_threads())   \
    firstprivate(uv1)

  for (i = 1; i <= ub_loop; i++) {
    state_ptr = (unsigned int(*)[625])state;
    eml_rand_mt19937ar(uv1);
    memcpy(&state[0], &uv1[0], 625U * sizeof(unsigned int));
    state_not_empty = true;
  }

  memcpy(&state_master[0], &state[0], 625U * sizeof(unsigned int));
  eml_rand_mt19937ar(uv0);
  memcpy(&state[0], &uv0[0], 625U * sizeof(unsigned int));
  state_not_empty = true;
}

//
// Arguments    : boolean_T aToMaster
// Return Type  : void
//
void c_eml_rand_mt19937ar_stateful_s(boolean_T aToMaster) {
  boolean_T state_not_empty_tmp;
  if (aToMaster) {
    state_ptr = (unsigned int(*)[625])state_master;
  } else {
    state_ptr = (unsigned int(*)[625])state;
  }

  state_not_empty_tmp = state_not_empty;
  state_not_empty = state_not_empty_master;
  state_not_empty_master = state_not_empty_tmp;
}

//
// Arguments    : void
// Return Type  : double
//
double eml_rand_mt19937ar_stateful() {
  return b_eml_rand_mt19937ar(*state_ptr);
}
