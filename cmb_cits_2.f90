module coordinate_random_mod
  implicit none
contains
  subroutine random_coordinate(thetam,phim)

    double precision :: pi1=4*atan(1.d0)
    double precision :: pi2=8*atan(1.d0)
    double precision :: rad=(4*atan(1.d0))/180.d0
    double precision :: p1, p2, p3
    double precision, intent(out) :: thetam, phim

    call random_number(p1)
    call random_number(p2)
    call random_number(p3)

    if ( p3>=0.d0 .and. p3<0.5d0 ) then
       thetam= acos(1.d0-p1)
    else if ( p3>=0.5d0 .and. p3<1.d0 ) then
       thetam=-acos(1.d0-p1)+pi1
    else
       write(*,*) 'Random_Coordinate Error'
    end if
    phim=pi2*p2

    return
  end subroutine random_coordinate
end module coordinate_random_mod
