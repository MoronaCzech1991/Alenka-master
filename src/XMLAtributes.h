#pragma once

#ifndef XMLATRIBUTES_H
#define XMLATRIBUTES_H

#include <QString>
#include <list>
#include "MontageXML.h"
#include "EventTypeXML.h"

using namespace std;

class XMLAtributes {

public:
	XMLAtributes();
	list<MontageXML> Montage;
	list<EventTypeXML> EventyType;
};

#endif