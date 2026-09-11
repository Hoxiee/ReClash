package main

import (
	"encoding/json"
	"sync"
	"time"
)

const (
	messageBatchInterval = 16 * time.Millisecond
	messageBatchSize     = 32
	messageQueueSize     = 256
	messagePriorityBurst = 8
	messageEvictAttempts = 4
)

var (
	stateMessageQueue        = make(chan Message, messageQueueSize)
	doctorStatusMessageQueue = make(chan Message, 1)
	priorityMessageQueue     = make(chan Message, messageQueueSize)
	bulkMessageQueue         = make(chan Message, messageQueueSize)
	doctorStatusQueueMu      sync.Mutex
)

func init() {
	go runMessageBatcher(stateMessageQueue, doctorStatusMessageQueue, priorityMessageQueue, bulkMessageQueue, sendMessageBatch)
}

type messageClass int

const (
	stateMessageClass messageClass = iota
	priorityMessageClass
	bulkMessageClass
)

func classOfMessage(message Message) messageClass {
	switch message.Type {
	case LoadedMessage, GeoUpdateMessage, DoctorStatusMessage:
		return stateMessageClass
	case LogMessage, RequestMessage:
		return bulkMessageClass
	default:
		return priorityMessageClass
	}
}

func shouldEnqueueMessage(message Message) bool {
	return classOfMessage(message) != bulkMessageClass || uiActive.Load()
}

func sendMessage(message Message) {
	if !shouldEnqueueMessage(message) {
		return
	}
	messageClass := classOfMessage(message)
	switch messageClass {
	case stateMessageClass:
		if message.Type == DoctorStatusMessage {
			enqueueDoctorStatus(message)
			return
		}
		enqueueState(stateMessageQueue, message)
	case bulkMessageClass:
		enqueueLatest(bulkMessageQueue, message)
	default:
		enqueueLatest(priorityMessageQueue, message)
	}
}

func enqueueState(queue chan Message, message Message) {
	select {
	case queue <- message:
	default:
	}
}

func enqueueDoctorStatus(message Message) {
	doctorStatusQueueMu.Lock()
	defer doctorStatusQueueMu.Unlock()
	select {
	case <-doctorStatusMessageQueue:
	default:
	}
	doctorStatusMessageQueue <- message
}

func enqueueLatest(queue chan Message, message Message) {
	for attempt := 0; attempt < messageEvictAttempts; attempt++ {
		select {
		case queue <- message:
			return
		default:
		}

		select {
		case <-queue:
		default:
		}
	}
}

func runMessageBatcher(
	stateMessages <-chan Message,
	doctorStatusMessages <-chan Message,
	priorityMessages <-chan Message,
	bulkMessages <-chan Message,
	send func([]Message),
) {
	timer := time.NewTimer(messageBatchInterval)
	if !timer.Stop() {
		<-timer.C
	}
	defer timer.Stop()

	var deadline <-chan time.Time
	batch := make([]Message, 0, messageBatchSize)

	flush := func() {
		if len(batch) == 0 {
			return
		}
		if !timer.Stop() {
			select {
			case <-timer.C:
			default:
			}
		}
		deadline = nil
		current := batch
		batch = make([]Message, 0, messageBatchSize)
		send(current)
	}
	appendMessage := func(message Message) {
		if len(batch) == 0 {
			timer.Reset(messageBatchInterval)
			deadline = timer.C
		}
		batch = append(batch, message)
		if len(batch) >= messageBatchSize {
			flush()
		}
	}

	priorityBurst := 0
	for stateMessages != nil || doctorStatusMessages != nil || priorityMessages != nil || bulkMessages != nil {
		select {
		case message, ok := <-stateMessages:
			if !ok {
				stateMessages = nil
			} else {
				appendMessage(message)
			}
			continue
		default:
		}

		select {
		case message, ok := <-doctorStatusMessages:
			if !ok {
				doctorStatusMessages = nil
			} else {
				appendMessage(message)
			}
			continue
		default:
		}

		// Give bulk events one guaranteed opportunity after a bounded priority
		// burst, while retaining priority preference under ordinary load.
		if priorityBurst >= messagePriorityBurst && bulkMessages != nil {
			select {
			case message, ok := <-bulkMessages:
				if !ok {
					bulkMessages = nil
				} else {
					appendMessage(message)
				}
				priorityBurst = 0
				continue
			default:
				priorityBurst = 0
			}
		}

		select {
		case message, ok := <-priorityMessages:
			if !ok {
				priorityMessages = nil
			} else {
				appendMessage(message)
				priorityBurst++
			}
			continue
		default:
		}

		select {
		case message, ok := <-stateMessages:
			if !ok {
				stateMessages = nil
			} else {
				appendMessage(message)
			}
		case message, ok := <-doctorStatusMessages:
			if !ok {
				doctorStatusMessages = nil
			} else {
				appendMessage(message)
			}
		case message, ok := <-priorityMessages:
			if !ok {
				priorityMessages = nil
			} else {
				appendMessage(message)
				priorityBurst++
			}
		case message, ok := <-bulkMessages:
			if !ok {
				bulkMessages = nil
			} else {
				appendMessage(message)
			}
			priorityBurst = 0
		case <-deadline:
			flush()
		}
	}
	flush()
}

type messageBatchCall struct {
	Method    CoreMethod `json:"method"`
	Arguments []Message  `json:"arguments"`
}

func sendMessageBatch(messages []Message) {
	data, err := json.Marshal(messageBatchCall{
		Method:    messageMethod,
		Arguments: messages,
	})
	if err != nil {
		logError("Message batch marshal error: %v", err)
		return
	}
	deliverEvent(data)
}
