#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This example demonstrates a random walk with pyqtgraph.
"""

from pyqtgraph.Qt import QtGui, QtCore
import numpy as np
import pyqtgraph as pg
        
class RandomWalkPlot:
    def __init__(self, win):
        #self.plot = pg.plot()
        self.plot = win.addPlot(title="Updating plot")
        
        self.ptr = 0
        
        #pen = 'r'
        pen = pg.mkPen('b', style=QtCore.Qt.SolidLine)
        self.curve = self.plot.plot(pen=pen, symbol='+')
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.update)
        self.timer.start(50)
        
        self.value = 1000 # initial value
        self.N = 100 # number of elements into circular buffer
        
        #self.buff = collections.deque([self.value]*N, maxlen=N)
        self.buff = self.value * np.ones(self.N)
        

    def update(self):
        self.value += np.random.uniform(-1, 1)

        self.buff = np.roll(self.buff, -1)
        self.buff[self.N-1] = self.value

        self.curve.setData(y=np.array(self.buff))

        #if self.ptr == 0:
        #    self.plot.enableAutoRange('xy', False)  ## stop auto-scaling after the first data set is plotted
        #self.ptr += 1

def main():
    #QtGui.QApplication.setGraphicsSystem('raster')
    app = QtGui.QApplication([])
    #mw = QtGui.QMainWindow()
    #mw.resize(800,800)

    pg.setConfigOption('background', 'w')
    pg.setConfigOption('foreground', 'k')

    win = pg.GraphicsWindow(title="Basic plotting examples")
    win.resize(1000,600)
    win.setWindowTitle('plot')

    # Enable antialiasing for prettier plots
    pg.setConfigOptions(antialias=True)
    
    upl = RandomWalkPlot(win)
    
    import sys
    ## Start Qt event loop unless running in interactive mode or using pyside.
    if (sys.flags.interactive != 1) or not hasattr(QtCore, 'PYQT_VERSION'):
        QtGui.QApplication.instance().exec_()

if __name__ == '__main__':
	main()