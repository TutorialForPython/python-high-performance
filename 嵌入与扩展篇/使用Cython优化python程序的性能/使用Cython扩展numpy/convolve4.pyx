# distutils: language=c++
import numpy as np##必须为c类型和python类型的数据都申明一个np

cimport numpy as np

DTYPE = np.int

ctypedef np.int_t DTYPE_t

cimport cython

@cython.boundscheck(False) # 关闭边界检查
@cython.wraparound(False)  # 关闭负指数换行
def naive_convolve_4(np.ndarray[DTYPE_t, ndim=2] f, np.ndarray[DTYPE_t, ndim=2] g):
    if g.shape[0] % 2 != 1 or g.shape[1] % 2 != 1:
        raise ValueError("Only odd dimensions on filter supported")
    assert f.dtype == DTYPE and g.dtype == DTYPE
    
    cdef int vmax = f.shape[0]
    cdef int wmax = f.shape[1]
    cdef int smax = g.shape[0]
    cdef int tmax = g.shape[1]
    cdef int smid = smax // 2
    cdef int tmid = tmax // 2
    cdef int xmax = vmax + 2*smid
    cdef int ymax = wmax + 2*tmid
    # “缓冲”语法
    cdef np.ndarray[DTYPE_t, ndim=2] h = np.zeros([xmax, ymax], dtype=DTYPE)
    cdef int s, t
    cdef unsigned int x, y, v, w 
   
    cdef int s_from, s_to, t_from, t_to
   
    cdef DTYPE_t value
    for x in range(xmax):
        for y in range(ymax):
            s_from = max(smid - x, -smid)
            s_to = min((xmax - x) - smid, smid + 1)
            t_from = max(tmid - y, -tmid)
            t_to = min((ymax - y) - tmid, tmid + 1)
            value = 0
            for s in range(s_from, s_to):
                for t in range(t_from, t_to):
                    v = <unsigned int>(x - smid + s)#指定类型
                    w = <unsigned int>(y - tmid + t)#指定类型
                    value += g[<unsigned int>(smid - s), <unsigned int>(tmid - t)] * f[v, w]#指定类型
            h[x, y] = value
    return h