program cits_main
  use correlation_mod
  implicit none
  integer :: rotation,thread,hi_p
  rotation=3000000
  thread=30
  hi_p=100
  write(*,*) 'rotation=',rotation
  write(*,*) 'hi_p=',hi_p
  write(*,*) 'thread=',thread
  call correlation(rotation,thread,hi_p)
end program cits_main

!gfortran -fopenmp -I/usr/local/lib/Healpix_3.20/include cmb_cits_3.f90 cmb_cits_2.f90 cmb_cits_1.f90 cmb_cits_main.f90 -o ./correlation.out -L/usr/local/lib/Healpix_3.20/lib -L/usr/local/cfitsio -lhealpix -lgif -lcfitsio

