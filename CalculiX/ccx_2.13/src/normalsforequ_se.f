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
      subroutine normalsforequ_se(nk,co,iponoelfa,inoelfa,konfa,
     &  ipkonfa,lakonfa,ne,iponor,xnor,nodedesiinv,jobnamef)
!
!     calculates normals on surface
!
      implicit none
!
      character*132 jobnamef,fnequ
      character*8 lakonfa(*),lakonfaloc
!
      integer nk,iponoelfa(*),inoelfa(3,*),konfa(*),ipkonfa(*),ne,
     &  i,ndepnodes,index,nexp,nnor,nel,ielem,indexe,j,iel(100),
     &  jl(100),ial(100),ifi(100),indexx,k,l,ifix,nemin,jact,ixfree,
     &  node,idim,iponor(*),nodedesiinv(*),len,ndet(3),nsort(3)
!
      real*8 co(3,*),xnor(*),xno(3,100),xi,et,coloc6(2,6),coloc8(2,8),
     &  xl(3,8),dd,xnoref(3),dot,xnorloc(3,3),det(3),sort(3)
!
      data coloc6 /0.d0,0.d0,1.d0,0.d0,0.d0,1.d0,0.5d0,0.d0,
     &             0.5d0,0.5d0,0.d0,0.5d0/
      data coloc8 /-1.d0,-1.d0,1.d0,-1.d0,1.d0,1.d0,-1.d0,1.d0,
     &            0.d0,-1.d0,1.d0,0.d0,0.d0,1.d0,-1.d0,0.d0/
!
!     calculating the normals in nodes belonging to shells
!
      do len=1,132
         if(jobnamef(len:len).eq.' ') exit
      enddo
      len=len-1
      
      fnequ=jobnamef(1:len)//'.equ'
      open(20,file=fnequ(1:len+4),status='unknown',err=100)
      close(20,status='delete',err=101)
      open(20,file=fnequ(1:len+4),status='unknown',err=100)
      write(20,102)
      write(20,103)
 102  format('**SUMMARY OF EUQATIONS FOR MESH-UPDATE ')
 103  format('*EQUATION')
!     
      ixfree=0
!     
      do i=1,nk
         if(i.eq.1699) then 
            ndepnodes=0
         endif
         ndepnodes=0
         idim=0
         index=iponoelfa(i)
         if(index.eq.0) cycle
!     
!     nexp indicates how many times the node was expanded
!     
         nexp=0
!     
!     nnor indicates whether the expanded nodes lie on a point
!     (nnor=0, only for plane stress, plane strain or axisymmetric
!     elements), on a line (nnor=1) or in a plane (nnor=2)
!     
         nnor=0
!     
!     locating the shell elements to which node i belongs
!     
         nel=0
         do
            if(index.eq.0) exit
            ielem=inoelfa(1,index)
            if(lakonfa(ielem)(1:1).eq.'S') nnor=1
            indexe=ipkonfa(ielem)
            nel=nel+1
            if(nel.gt.100) then
               write(*,*) '*ERROR in normalsforequ_se: more '
               write(*,*) '  than 100 shell elements '
               write(*,*) '  share the same node'
               call exit(201)
            endif
            j=inoelfa(2,index)
            jl(nel)=j
            iel(nel)=ielem
            index=inoelfa(3,index)
         enddo
!     
         if(nel.gt.0) then
            do j=1,nel
               ial(j)=0
            enddo
!     
!     estimate the normal
!     
            do j=1,nel
               indexe=ipkonfa(iel(j))
               indexx=iponor(indexe+jl(j))
               if(indexx.ge.0) then
                  do k=1,3
                     xno(k,j)=xnor(indexx+k)
                  enddo
                  ifi(j)=1
                  cycle
               else
                  ifi(j)=0
               endif
!     
!     local normal on the element (Jacobian)
!     
               lakonfaloc=lakonfa(iel(j))
               if(lakonfa(iel(j))(2:2).eq.'3') then
                  xi=coloc6(1,jl(j))
                  et=coloc6(2,jl(j))
                  do k=1,3
                     node=konfa(indexe+k)
                     do l=1,3
                        xl(l,k)=co(l,node)
                     enddo
                  enddo
                  call norshell3(xi,et,xl,xno(1,j))
               elseif(lakonfa(iel(j))(2:2).eq.'4') then
                  xi=coloc8(1,jl(j))
                  et=coloc8(2,jl(j))
                  do k=1,4
                     node=konfa(indexe+k)
                     do l=1,3
                        xl(l,k)=co(l,node)
                     enddo
                  enddo
                  call norshell4(xi,et,xl,xno(1,j))
               elseif(lakonfa(iel(j))(2:2).eq.'6') then
                  xi=coloc6(1,jl(j))
                  et=coloc6(2,jl(j))
                  do k=1,6
                     node=konfa(indexe+k)
                     do l=1,3
                        xl(l,k)=co(l,node)
                     enddo
                  enddo
                  call norshell6(xi,et,xl,xno(1,j))
               elseif(lakonfa(iel(j))(2:2).eq.'8') then
                  xi=coloc8(1,jl(j))
                  et=coloc8(2,jl(j))
                  do k=1,8
                     node=konfa(indexe+k)
                     do l=1,3
                        xl(l,k)=co(l,node)
                     enddo
                  enddo
                  call norshell8(xi,et,xl,xno(1,j))
               endif
!     
               dd=dsqrt(xno(1,j)**2+xno(2,j)**2+xno(3,j)**2)
               if(dd.lt.1.d-10) then
                  write(*,*) '*ERROR in normalsforequ_se: size '
                  write(*,*) '       of estimatedshell normal in 
     &node ',i,' element ',iel(j)
                  write(*,*) '       is smaller than 1.e-10'
                  call exit(201)
               endif
               do k=1,3
                  xno(k,j)=xno(k,j)/dd
               enddo
            enddo
!     
            do
!     
!     determining a fixed normal which was not treated yet,
!     or, if none is left, the minimum element number of all
!     elements containing node i and for which no normal was
!     determined yet
!     
!     if ial(j)=0: the normal on this element has not been
!     treated yet
!     if ial(j)=2: normal has been treated
!     
               ifix=0
               nemin=ne+1
               do j=1,nel
                  if(ial(j).ne.0) cycle
                  if(ifi(j).eq.1) then
                     jact=j
                     ifix=1
                     exit
                  endif
               enddo
               if(ifix.eq.0) then
                  do j=1,nel
                     if(ial(j).eq.0) then
                        if(iel(j).lt.nemin) then
                           nemin=iel(j)
                           jact=j
                        endif
                     endif
                  enddo
                  if(nemin.eq.ne+1) exit
               endif
!     
               do j=1,3
                  xnoref(j)=xno(j,jact)
               enddo
!     
!     determining all elements whose normal in node i makes an
!     angle smaller than 0.5 or 20 degrees with the reference normal,
!     depending whether the reference normal was given by the
!     user or is being calculated; the thickness and offset must
!     also fit.
!     
!     if ial(j)=1: normal on element is being treated now
!     
               do j=1,nel
                  if(ial(j).eq.2) cycle
                  if(j.eq.jact) then
                     ial(jact)=1
                  else
                     dot=xno(1,j)*xnoref(1)+xno(2,j)*xnoref(2)+
     &                    xno(3,j)*xnoref(3)
                     if(ifix.eq.0) then
                        if(dot.gt.0.939693d0)then
                           if((lakonfa(iel(j))(1:3).eq.
     &                          lakonfa(iel(jact))(1:3))
     &                          .or.
     &                          ((lakonfa(iel(j))(1:1).eq.'S').and.
     &                          (lakonfa(iel(jact))(1:1).eq.'S')))
     &                          ial(j)=1
c     
                           if(dot.lt.0.999962d0) nnor=2
c     
                        else
                           if((lakonfa(iel(j))(1:1).eq.'S').and.
     &                          (lakonfa(iel(jact))(1:1).eq.'S')) then
!     
!     if the normals have the opposite
!     direction, the expanded nodes are on a
!     straight line
!     
                              if(dot.gt.-0.999962) then
                                 nnor=2
                              else
                                 write(*,*) '*INFO in gen3dnor: in some 
     &nodes opposite normals are defined'
                              endif
                           endif
                        endif
                     else
                        if(dot.gt.0.999962d0) then
                           if((lakonfa(iel(j))(1:3).eq.
     &                          lakonfa(iel(jact))(1:3))
     &                          .or.
     &                          ((lakonfa(iel(j))(1:1).eq.'S').and.
     &                          (lakonfa(iel(jact))(1:1).eq.'S')))
     &                          ial(j)=1
                        else
                           if((lakonfa(iel(j))(1:1).eq.'S').and.
     &                          (lakonfa(iel(jact))(1:1).eq.'S')) then
!     
!     if the normals have the opposite
!     direction, the expanded nodes are on a
!     straight line
!     
                              if(dot.gt.-0.999962) then
                                 nnor=2
                              else
                                 write(*,*) '*INFO in gen3dnor: in some
     &nodes opposite normals are defined'
                              endif
                           endif
                        endif
                     endif
                  endif
               enddo
!     
!     determining the mean normal for the selected elements
!     
               if(ifix.eq.0) then
                  do j=1,3
                     xnoref(j)=0.d0
                  enddo
                  do j=1,nel
                     if(ial(j).eq.1) then
                        do k=1,3
                           xnoref(k)=xnoref(k)+xno(k,j)
                        enddo
                     endif
                  enddo
                  dd=dsqrt(xnoref(1)**2+xnoref(2)**2+xnoref(3)**2)
                  if(dd.lt.1.d-10) then
                     write(*,*) '*ERROR in gen3dnor: size of'
                     write(*,*) '        estimated shell normal is'
                     write(*,*) '        smaller than 1.e-10'
                     call exit(201)
                  endif
                  do j=1,3
                     xnoref(j)=xnoref(j)/dd
                  enddo
               endif
!     
!     updating the pointers iponor
!     
               nexp=nexp+1
               do j=1,nel
                  if(ial(j).eq.1) then
                     ial(j)=2
                     if(ifix.eq.0) then
                        iponor(ipkonfa(iel(j))+jl(j))=ixfree
                     elseif(j.ne.jact) then
                        iponor(ipkonfa(iel(j))+jl(j))=
     &                       iponor(ipkonfa(iel(jact))+jl(jact)) 
                     endif
                  endif
               enddo
!     
!     storing the normal in xnor and generating 3 nodes
!     for knor
!     
               if(ifix.eq.0) then
                  do j=1,3
                     xnor(ixfree+j)=xnoref(j)
                  enddo
                  ixfree=ixfree+3
               endif
!     
            enddo
         endif
!     
!     write equations in file "jobname.equ"
!     
!     check if node is a designvariable
!     
         if(nodedesiinv(i).eq.0) then
!     
!     write equations in case nexp is greater or equal 3
!     
            if(nexp.ge.3) then
               do j=1,3
                  write(20,106) 1
                  write(20,105) i,j,1
               enddo
!     
!     write equations in case nexp is 1
!     
            elseif(nexp.eq.1) then
               j=1
               do l=1,3
                  xnorloc(4-l,j)=xnor(ixfree+1-l)
                  sort(4-l)=dabs(xnor(ixfree+1-l))
                  nsort(4-l)=4-l            
               enddo
               call dsort(sort,nsort,3,2)
               write(20,106) 3  
               write(20,104) i,nsort(3),xnorloc(nsort(3),1),
     &              i,nsort(2),xnorloc(nsort(2),1),
     &              i,nsort(1),xnorloc(nsort(1),1)
!     
!     write equations in case nexp is 2
!     
            elseif(nexp.eq.2) then
               do j=1,nexp
                  k=j*3-3
                  do l=1,3
                     xnorloc(4-l,j)=xnor(ixfree+1-l-k)
                  enddo
               enddo
               if(i.eq.5457) then
                  ndet(1)=1
               endif
               ndet(1)=1
               ndet(2)=2
               ndet(3)=3
               det(1)=dabs(xnorloc(1,1)*xnorloc(2,2)-
     &              xnorloc(1,2)*xnorloc(2,1))
               det(2)=dabs(xnorloc(1,1)*xnorloc(3,2)-
     &              xnorloc(1,2)*xnorloc(3,1))
               det(3)=dabs(xnorloc(2,1)*xnorloc(3,2)-
     &              xnorloc(2,2)*xnorloc(3,1))
               call dsort(det,ndet,3,2)
               
               if(ndet(3).eq.1) then
!     if((dabs(xnorloc(1,1)).ge.dabs(xnorloc(2,1))).and.
!     &               (dabs(xnorloc(2,2)).gt.1.d-5)) then
                  if((dabs(xnorloc(1,1)).gt.1.d-5).and.
     &                 (dabs(xnorloc(2,2)).gt.1.d-5)) then
                     write(20,106) 2  
                     write(20,107) i,1,xnorloc(1,1),
     &                    i,2,xnorloc(2,1)
                     write(20,106) 2  
                     write(20,107) i,2,xnorloc(2,2),
     &                    i,1,xnorloc(1,2)
                  else
                     write(20,106) 2  
                     write(20,107) i,2,xnorloc(2,1),
     &                    i,1,xnorloc(1,1)
                     write(20,106) 2  
                     write(20,107) i,1,xnorloc(1,2),
     &                    i,2,xnorloc(2,2)
                  endif
               elseif(ndet(3).eq.2) then
!     if((dabs(xnorloc(1,1)).ge.dabs(xnorloc(3,1))).and.
!     &                (dabs(xnorloc(3,2)).gt.1.d-5)) then
                  if((dabs(xnorloc(1,1)).gt.1.d-5).and.
     &                 (dabs(xnorloc(3,2)).gt.1.d-5)) then
                     write(20,106) 2  
                     write(20,107) i,1,xnorloc(1,1),
     &                    i,3,xnorloc(3,1)
                     write(20,106) 2  
                     write(20,107) i,3,xnorloc(3,2),
     &                    i,1,xnorloc(1,2)
                  else
                     write(20,106) 2  
                     write(20,107) i,3,xnorloc(3,1),
     &                    i,1,xnorloc(1,1)
                     write(20,106) 2  
                     write(20,107) i,1,xnorloc(1,2),
     &                    i,3,xnorloc(3,2)
                  endif
               elseif(ndet(3).eq.3) then
!     if((dabs(xnorloc(2,1)).ge.dabs(xnorloc(3,1))).and.
!     &                (dabs(xnorloc(3,2)).gt.1.d-5)) then
                  if((dabs(xnorloc(2,1)).gt.1.d-5).and.
     &                 (dabs(xnorloc(3,2)).gt.1.d-5)) then
                     write(20,106) 2  
                     write(20,107) i,2,xnorloc(2,1),
     &                    i,3,xnorloc(3,1)
                     write(20,106) 2  
                     write(20,107) i,3,xnorloc(3,2),
     &                    i,2,xnorloc(2,2)
                  else
                     write(20,106) 2  
                     write(20,107) i,3,xnorloc(3,1),
     &                    i,2,xnorloc(2,1)
                     write(20,106) 2  
                     write(20,107) i,2,xnorloc(2,2),
     &                    i,3,xnorloc(3,2)
                  endif     
               endif
            endif          
         endif
!     
 104     format(3(i10,",",i1,",",e20.13,","))
 105     format(1(i10,",",i1,",",i1,","))
 106     format(i1)
 107     format(2(i10,",",i1,",",e20.13,","))
!     
      enddo
      close(20)
!     
      return
!     
 100  write(*,*) '*ERROR in openfile: could not open file ',
     &     fnequ(1:len+4)
      call exit(201)
 101  write(*,*) '*ERROR in openfile: could not delete file ',
     &     fnequ(1:len+4) 
      call exit(201)
!     
      end
      
