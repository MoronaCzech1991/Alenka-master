#pragma once

#ifndef TRACKTABLEXML_H
#define TRACKTABLEXML_H

#include <QString>
using namespace std;

class TrackTableXML {

public:
	string Label;
	string Color;
	double Amplitude;
	bool Hidden;
	float X;
	float Y;
	float Z;
	string Code;
};

#endif
