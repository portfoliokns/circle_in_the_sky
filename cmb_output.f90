program cmb_output
	use healpix_types
	use healpix_modules
	use fitstools, only: getsize_fits, input_map
	
	implicit none
	
	integer :: npixtot,nmaps,ordering,nside,i,j,fo
	double precision, allocatable :: map(:,:)
	character :: mapfits*200, fname*80
	
	!fit2map----------------------------------------------------------------
	mapfits='/home/konishi/study/CMB_data/P-lanck/data/commander/COM_CMB_IQU-commander_256_R2.02_full.fits'
	write(*,*) 'mapfits=',mapfits
	npixtot=getsize_fits(mapfits,nmaps=nmaps,ordering=ordering,nside=nside)
	allocate(map(0:npixtot-1,1:nmaps))
	call input_map(mapfits,map,npixtot,nmaps)
	!-----------------------------------------------------------------------
	
	!para2dat---------------------------------
	write(fname,"('map_parameter.dat')")
	open(fo,file=fname)
	write(fo,*) npixtot
	write(fo,*) nmaps
	write(fo,*) ordering
	write(fo,*) nside
	close(fo)
	write(*,*) 'npixtot=',npixtot
	write(*,*) 'nmaps=',nmaps
	write(*,*) 'ordering=',ordering
	write(*,*) 'nside=',nside
	!-----------------------------------------
	
	!map2dat----------------------------------
	write(fname,"('map_data.dat')")
	open(fo,file=fname)
	do i=1,nmaps
		do j=0,npixtot-1
			write(fo,*) map(j,i)
		end do
	end do
	close(fo)
	write(*,*) '-----Complete-----'
	!------------------------------------------
	
end program cmb_output

!gfortran -fopenmp -I/usr/local/lib/Healpix_3.20/include cmb_output.f90 -o ./map.out -L/usr/local/lib/Healpix_3.20/lib -L/usr/local/cfitsio -lhealpix -lgif -lcfitsio
	
