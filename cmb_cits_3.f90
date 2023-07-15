module coordinate_rotation_mod
  implicit none
contains
  subroutine euler_coordinate(theta,phi,thetam,phim,theta1,phi1)

    double precision :: pi1=4*atan(1.d0)
    double precision :: pi2=8*atan(1.d0)
    double precision :: rad=(4*atan(1.d0))/180.d0
    double precision, intent(in) :: thetam,phim,theta,phi
    double precision, intent(out) :: theta1,phi1
    double precision :: x,y,z,y1,z1

    x=sin(theta)*cos(phi)
    y=sin(theta)*sin(phi)
    z=cos(theta)

    y1= y*cos(thetam)+z*sin(thetam)
    z1=-y*sin(thetam)+z*cos(thetam)

    theta1=acos(z1)
    phi1=atan2(y1,x)+phim
    if ( phi<0.d0 ) phi1=phi1+pi2

    return
  end subroutine euler_coordinate
end module coordinate_rotation_mod
