! BSD 2-Clause License
!
! Copyright (c) 2021-2023, Hewlett Packard Enterprise
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
!
! 1. Redistributions of source code must retain the above copyright notice, this
!    list of conditions and the following disclaimer.
!
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
! DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
! FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module fortran_c_interop

use iso_c_binding, only : c_ptr, c_char, c_size_t, c_loc, c_null_ptr, c_int
use iso_fortran_env, only : stderr => error_unit

implicit none; private

integer, parameter, public :: enum_kind = c_int !< The kind of integer equivalent to a C enum. According
                                                !! to the standard this is a c_int
integer, parameter, public :: C_MAX_STRING = 255 !< A bug in gfortran prevents the use of deferred length, allocatable
                                                 !! character arrays. This parameter specifies the maximum length of a
                                                 !! string passed to the C interface
#include "enum_fortran.inc"
public :: convert_char_array_to_c

contains

!> Returns pointers to the start of each string and lengths for each string in a Fortran character array
function convert_char_array_to_c(character_array_f, character_array_c, string_ptrs, ptr_to_string_ptrs, &
                                   string_lengths, ptr_to_string_lengths, n_strings ) result(code)
  !> The 2D Fortran character array
  character(len=*),             dimension(:),                      intent(in   ) :: character_array_f
  !> The character array converted to c_character types
  character(kind=c_char,len=C_MAX_STRING), dimension(:), allocatable, target, intent(  out) :: character_array_c
  !> C-style pointers to the start of each string
  type(c_ptr),                  dimension(:), allocatable, target, intent(  out) :: string_ptrs
  !> A pointer to the the string pointers
  type(c_ptr),                                                     intent(  out) :: ptr_to_string_ptrs
  !> The length of each string
  integer(kind=c_size_t),       dimension(:), allocatable, target, intent(  out) :: string_lengths
  !> Pointer to the array containing the string_lengths
  type(c_ptr),                                                     intent(  out) :: ptr_to_string_lengths
  !> The length of each string
  integer(kind=c_size_t),                                          intent(  out) :: n_strings
  integer(kind=enum_kind) :: code

  integer :: max_length, length
  integer(kind=c_size_t) :: i

  code = SRNoError
  ! Find the size of the 2D array and allocate some of the 1D arrays
  n_strings= size(character_array_f)
  allocate(string_lengths(n_strings))
  allocate(string_ptrs(n_strings))
  allocate(character_array_c(n_strings))

  ! Need to find the length of the string, so we can allocate the c_array
  max_length = 0
  do i=1,n_strings
    length = len_trim(character_array_f(i))
    max_length = max(max_length, length)
    string_lengths(i) = length
  enddo
  if (max_length > C_MAX_STRING) then
    code = SRRuntimeError
    write(stderr,*) "Length of string exceeded, increase C_MAX_STRING and recompile"
  endif
  ptr_to_string_lengths = c_loc(string_lengths)

  ! Copy the character into a c_char and create pointers to each of the strings
  do i=1,n_strings
     if (string_lengths(i) .gt. 0) then
        character_array_c(i) = character_array_f(i)
        string_ptrs(i) = c_loc(character_array_c(i))
     else
        string_ptrs(i) = c_null_ptr;
     endif
  enddo
  ptr_to_string_ptrs = c_loc(string_ptrs)

end function convert_char_array_to_c

end module fortran_c_interop
