#pragma once
#ifndef COMPARATORXML_H
#define COMPARATORXML_H

#include "XMLAtributes.h"
#include "pugixml.hpp"

#include <iostream>
// #include <AlenkaFile\eep.h>

/*
Brief this class is important for comparre the XML files and upadate the data comfiguration 
The class has three objects
The XMLDefault is the object that constain the base connfiguration
The XMLComparable its the new data 
The XMLResult is the object that old contais the configuration with the new data
*/

class ComparatorXML {

public:
	ComparatorXML();
	void LoadXMLDefault(const char* fileName);
	void LoadXMLComparable(const char* fileName);
	enum ModelDoc { EnumXMLDefault, EnumXMLComparable };
	void CreateResult();
	TrackTableXML ReturnTrackTableFromResult(int montagePosition, int trackPosition);
	list<MontageXML> ReturnResultMontage();
	list<EventTypeXML> ReturnResultEvents();
	EventTypeXML ReturnEventFromResult(int position);
    list<MontageXML> ReturnMontageComparable();
    list<EventTypeXML> ReturnEventComparable();

private:
	pugi::xml_document* DocXMLDefault;
	pugi::xml_document* DocXMLComparable;
	XMLAtributes* XMLDefault; // This is the montage that we want maintain the configuration
	XMLAtributes* XMLComparable; // This is the new montage, so we just must maintain the labels and the codes  
	XMLAtributes* XMLResult; // This the final montage, it is the combination 

	// methods 
	void LoadAtributesFromXMLFile(pugi::xml_parse_result result, ModelDoc model);
	void CreateXMLAtributes(XMLAtributes* xml, pugi::xml_document* document);

	// Methods for load the atributes from file 
	void CreateMontageAtributes(XMLAtributes* xml, pugi::xml_document* document);
	list<TrackTableXML> CreateListTrackTableAtributes(pugi::xml_node node, MontageXML montage );
	
	// Methods to operate 
	int CountMontages(ModelDoc model);
	int CountTrackTable(MontageXML montage);
	void CompareDocumentsXML();
	MontageXML ReturnMontage(ModelDoc model, int position);
	int CalculateDiferenceTracks(MontageXML montageDefault, MontageXML montageComparable);
	TrackTableXML ReturnTrackTable(MontageXML montage, int position);
    TrackTableXML CreateTrackResult(TrackTableXML defaultXML, TrackTableXML comparable);
	TrackTableXML CreateTrackResult(TrackTableXML comparable);
	void CleanXMLAtributes(XMLAtributes* xmlAtributes);
	int RevertPosition(int numberTracks, int position);
	void CreateEventsAtributes(XMLAtributes* xml, pugi::xml_document* document);
	EventTypeXML ReturnEvent(ModelDoc model, int position);
};

#endif
