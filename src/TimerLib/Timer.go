package main

import (
	"fmt"
	"time"
)

type evtHandler func(int)

type goTimer struct {
	tval      int
	r         int
	evtHand   evtHandler
	ss        bool
	exp_count int
}

type timerWheel struct {
	numSlots int
	R        int
	curSlot  int
	slot     [10]goTimer
}

func basicExpHandler(val int) {
	fmt.Println(val, "Timer Expired")
}

func (gt goTimer) startTimer(tw *timerWheel) {
	//f gt.tval > tw.numSlots {
	gt.r = gt.tval * gt.exp_count / tw.numSlots

	
	tw.slot[(gt.tval+tw.curSlot)%tw.numSlots] = gt
	tw.slot[(gt.tval+tw.curSlot)%tw.numSlots].evtHand = basicExpHandler

	
}

func (tw *timerWheel) startWheel(c chan string) {
	for {
		
		fmt.Println("TW R = ", tw.R, " cur slot = ", tw.curSlot, " r = ", tw.slot[tw.curSlot].r)
		if tw.slot[tw.curSlot].evtHand != nil {

			if tw.slot[tw.curSlot].r == tw.R {

				tw.slot[tw.curSlot].evtHand(tw.slot[tw.curSlot].tval)
				if tw.slot[tw.curSlot].ss == false {
					tw.slot[tw.curSlot].evtHand = nil
				} else {
					tw.slot[tw.curSlot].evtHand = nil
					tw.slot[tw.curSlot].exp_count++
					tw.slot[tw.curSlot].startTimer(tw)
				}
			}

		}
		tw.curSlot++
		if tw.curSlot > 9 {
			tw.curSlot = 0
			tw.R++
		}
		time.Sleep(1 * time.Second)
	}
	c <- "done"

}

func main() {

	var tw timerWheel
	tw.R = 0

	tw.numSlots = 10
	c := make(chan string)
	go tw.startWheel(c)
	var t1 goTimer
	var t2 goTimer
	var t3 goTimer

	t1.tval = 1
	t1.ss = false
	t1.exp_count = 1
	t1.evtHand = basicExpHandler

	t2.tval = 4
	t2.ss = true
	t2.exp_count = 1
	t2.evtHand = basicExpHandler

	t3.tval = 17
	t3.ss = true
	t3.exp_count = 1
	t3.evtHand = basicExpHandler

	t1.startTimer(&tw)
	t2.startTimer(&tw)
	t3.startTimer(&tw)

	<-c
}
