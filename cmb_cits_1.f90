module correlation_mod
  use coordinate_random_mod
  use coordinate_rotation_mod
  use pix_tools, only: ang2pix_ring,ang2pix_nest
  implicit none
contains
  subroutine correlation(rotation,thread,hi_p)

    integer, intent(in) :: rotation,thread,hi_p
    integer :: npixtot,nmaps,ordering,nside,fo
    integer :: ntot,i,j
    integer :: hi_n,count_total
    double precision :: pi1=4*atan(1.d0),pi2=8*atan(1.d0),rad=(4*atan(1.d0))/180.d0
    double precision :: omega_pix,theta_pix,base_theta1,base_theta2,h,theta_deg,thetam,phim
    double precision :: Atotal,Btotal,Ctotal
    double precision :: hi_d,hi_v
    integer, allocatable :: ip1(:,:),ip2(:,:),hi_c(:)
    double precision, allocatable :: map(:,:),base_phi(:)
    double precision, allocatable :: euler_theta1(:,:),euler_phi1(:,:),euler_theta2(:,:),euler_phi2(:,:)
    double precision, allocatable :: T1(:,:),T2(:,:),resulty(:),w1(:),w2(:),w3(:),w4(:),w5(:)
    character :: fname*80
    
    !dat2map---------------------------------
    write(fname,"('map_parameter.dat')")
    open(fo,file=fname)
    read(fo,*) npixtot
    read(fo,*) nmaps
    read(fo,*) ordering
    read(fo,*) nside
    close(fo)
    write(*,*) 'npixtot=',npixtot
    write(*,*) 'nmaps=',nmaps
    write(*,*) 'ordering=',ordering
    write(*,*) 'nside=',nside
    !-----------------------------------------
    
    !dat2map----------------------------------
    write(fname,"('map_data.dat')")
    write(*,*) 'Now, Loading map_dat.dat!'
    allocate(map(0:npixtot-1,1:nmaps))
    open(fo,file=fname)
    do i=1,nmaps
       do j=0,npixtot-1
          read(fo,*) map(j,i)
       end do
    end do
    close(fo)
    write(*,*) 'Finish Loading CMB-Data!'
    !------------------------------------------
    
    !Pixel-Size-----------------------------------------
    omega_pix=(4*pi1)/npixtot
    theta_pix=sqrt(omega_pix)
    write(*,*) 'theta_pix=',theta_pix/rad,'degree'
    !---------------------------------------------------
    
    !Circle-Size----------------------------------------
    write(*,*) 'Input a circle size. theta=...degree. '
    write(*,*) 'ex) theta=15.10 ==> 15.10'
    read(*,*) theta_deg
    write(*,*) 'Circle size is theta=',theta_deg,'degree.'
    base_theta1=theta_deg*rad
    base_theta2=pi1-base_theta1
    ntot=(pi2*sin(base_theta1))/theta_pix
    h=pi2/ntot

    !allocate section....................
    allocate(base_phi(0:ntot-1))
    allocate(euler_theta1(0:ntot-1,1:rotation),euler_phi1(0:ntot-1,1:rotation))
    allocate(euler_theta2(0:ntot-1,1:rotation),euler_phi2(0:ntot-1,1:rotation))
    allocate(T1(0:ntot-1,1:rotation),T2(0:ntot-1,1:rotation))
    allocate(ip1(0:ntot-1,1:rotation),ip2(0:ntot-1,1:rotation))
    allocate(resulty(1:rotation))
    !....................................	
    
    do i=0,ntot-1
       base_phi(i)=h*i
    end do
    !----------------------------------------------------
    
    !CITS Correlation-----------------------------------------------------------------------------------
    !$omp parallel num_threads(thread)
    !$omp do private(i,j,thetam,phim,Atotal,Btotal,Ctotal)
    do i=1,rotation
       
       !Monte-Carlo for theta and phi
       call random_coordinate(thetam,phim)
       !print *, thetam,phim
       !----------------------------------
       
       !Euler-Coordinate-------------------------------------------------------------------------------
       do j=0,ntot-1
          call euler_coordinate(base_theta1,base_phi(j),thetam,phim,euler_theta1(j,i),euler_phi1(j,i))
          call euler_coordinate(base_theta2,base_phi(j),thetam,phim,euler_theta2(j,i),euler_phi2(j,i))
          !print *, euler_theta1,euler_theta2
       end do
       !------------------------------------------------------------------------------------------------
       
       !Pixel-Number---------------------------------------------------------------
       if (ordering==1) then
          do j=0,ntot-1
             call ang2pix_ring(nside,euler_theta1(j,i),euler_phi1(j,i),ip1(j,i))
             call ang2pix_ring(nside,euler_theta2(j,i),euler_phi2(j,i),ip2(j,i))
          end do
       else if (ordering==2) then
          do j=0,ntot-1
             call ang2pix_nest(nside,euler_theta1(j,i),euler_phi1(j,i),ip1(j,i))
             call ang2pix_nest(nside,euler_theta2(j,i),euler_phi2(j,i),ip2(j,i))
          end do
       else
          write(*,*) 'ang2pix Error ordering=/0,1'
       end if
       !----------------------------------------------------------------------------
       
       !Temparature on the Pixel-Number
       do j=0,ntot-1
          T1(j,i)=map(ip1(j,i),1)
          T2(j,i)=map(ip2(j,i),1)
       end do
       !--------------------------------
       
       !Correlation for CITS-------------------
       Atotal=0.d0
       Btotal=0.d0
       Ctotal=0.d0
       do j=0,ntot-1
          Atotal=Atotal+T1(j,i)*T2(j,i)
          Btotal=Btotal+T1(j,i)**2
          Ctotal=Ctotal+T2(j,i)**2
       end do
       resulty(i)=Atotal/(sqrt(Btotal*Ctotal))
       !----------------------------------------
       
    end do
    !$omp end do
    !$omp end parallel
    !---------------------------------------------------------------------------------------

    !deallocate section.......................
    deallocate(euler_theta1,euler_phi1,euler_theta2,euler_phi2,T1,T2,ip1,ip2)
    !.........................................


    !Initial condition about Histgram parameter
    hi_n=2*hi_p    !Histgram number    !Ex.2*20 2*40  2*80
    hi_d=dble(1.d0/hi_p)    !The width of bin   !Ex.0.05 0.025 0.0125 ==bin
    !Just, "hi_n*hi_d=2"
    !-----------------------

    !allocate section.....................
    allocate(hi_c(1:hi_n))
    allocate(w1(1:hi_n),w2(1:hi_n),w3(1:hi_n),w4(1:hi_n),w5(1:hi_n))
    !.....................................

    !Count Total-----------------------------------------
    !$omp parallel num_threads(thread)
    !$omp do private(i,j,hi_v,count_total)
    do i=1,hi_n
       hi_v=-1.d0+hi_d*(i-1)
       count_total=hi_c(i)
       do j=1,rotation
          if ( hi_v<resulty(j) .and. resulty(j)<=hi_v+hi_d ) then
             count_total=count_total+1
          end if
       end do
       hi_c(i)=count_total
    end do
    !$omp end do
    !$omp end parallel
    !----------------------------------------------------

    !Standardization of distribution for mathematica.
    !$omp parallel num_threads(thread)
    !$omp do private(i,hi_v,count_total)
    do i=1,hi_n
       w1(i)=-1.d0-0.5d0*hi_d+hi_d*i
       w2(i)=(hi_c(i))/dble(rotation*hi_d)
       if ( hi_c(i)>1 )then
          w3(i)=(int(hi_c(i)**0.5d0)+1)/dble(rotation*hi_d)
       else if ( hi_c(i)==1 ) then
          w3(i)=(int(hi_c(i)**0.5d0))/dble(rotation*hi_d)
       else
          w3(i)=0.d0
       end if
       w4(i)=w1(i)-hi_d/2
       w5(i)=w1(i)+hi_d/2
    end do
    !$omp end do
    !$omp end parallel
    !----------------

    !writting dat--------------------
    write(fname,"('result.dat')")
    open(fo,file=fname)
    do i=1,hi_n
       write(fo,'(f15.5,f25.15,f25.15)') w1(i),w2(i),w3(i)
    end do
    close(fo)
    !--------------------------------
    

    !deallocate section..................
    deallocate(base_phi,resulty,w1,w2,w3,w4,w5,hi_c)
    !....................................
    
    return
  end subroutine correlation
end module correlation_mod


