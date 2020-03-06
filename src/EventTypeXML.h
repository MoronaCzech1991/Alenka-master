#pragma once

#ifndef EVENTTYPEXML_H
#define EVENTTYPEXML_H


#include <QString>
using namespace std; 

class EventTypeXML {

public:
	EventTypeXML();

	int Id;
	string Name;
	double Opacity;
	string Color;
	bool Hidden;
};

#endif