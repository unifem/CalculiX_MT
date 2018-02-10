!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2017 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
      subroutine calcrhoelcomp(nef,vel,shcon,ielmat,ntmat_,
     &  mi)
!
!     calculation of rho in the element centers (compressible
!     fluids)
!
      implicit none
!
      integer nef,i,imat,ntmat_,mi(*),
     &  ielmat(mi(3),*)
!
      real*8 t1l,vel(nef,0:7),shcon(0:3,ntmat_,*)
!     
c$omp parallel default(none)
c$omp& shared(nef,vel,ielmat,shcon)
c$omp& private(i,t1l,imat)
c$omp do
      do i=1,nef
         t1l=vel(i,0)
         imat=ielmat(1,i)
         vel(i,5)=vel(i,4)/(shcon(3,1,imat)*t1l)
      enddo
c$omp end do
c$omp end parallel
!            
      return
      end
