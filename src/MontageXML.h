#pragma once

#ifndef MONTAGEXML_H
#define MONTAGEXML_H

#include <list>
#include "TrackTableXML.h"
#include "EventTypeXML.h"

using namespace std;

class MontageXML  {

public:
	MontageXML();
	string Name;
	bool Save;
	list<TrackTableXML> TrackTable;
	list<EventTypeXML> Events;
};

#endif
