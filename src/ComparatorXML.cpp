#include "ComparatorXML.h"
#include "pugixml.hpp"

#include <iostream>
#include <vector>

using namespace std;

	ComparatorXML::ComparatorXML()
	{
		DocXMLDefault = new pugi::xml_document();
		DocXMLComparable = new pugi::xml_document();
		XMLDefault = new XMLAtributes();
		XMLComparable = new XMLAtributes();
		XMLResult = new XMLAtributes();
	}

	void ComparatorXML::LoadXMLDefault(const char* fileName)
	{
		this->CleanXMLAtributes(this->XMLDefault);
		pugi::xml_parse_result result = this->DocXMLDefault->load_file(fileName);
		this->LoadAtributesFromXMLFile(result, ComparatorXML::ModelDoc::EnumXMLDefault);
		this->XMLDefault->Montage.reverse();
	}

	void ComparatorXML::LoadXMLComparable(const char* fileName)
	{
		this->CleanXMLAtributes(this->XMLComparable);
		pugi::xml_parse_result result = this->DocXMLComparable->load_file(fileName);
		this->LoadAtributesFromXMLFile(result, ComparatorXML::ModelDoc::EnumXMLComparable);
		this->XMLComparable->Montage.reverse();
	}

	void ComparatorXML::CreateResult()
	{
		this->CompareDocumentsXML();
		this->XMLResult->Montage.reverse();
	}

	void ComparatorXML::LoadAtributesFromXMLFile(pugi::xml_parse_result result, ModelDoc model)
	{
		if (result)
		{
			switch (model)
			{
			case ComparatorXML::ModelDoc::EnumXMLDefault:
				this->CreateXMLAtributes(this->XMLDefault, this->DocXMLDefault);
				break;

			case ComparatorXML::ModelDoc::EnumXMLComparable:
				this->CreateXMLAtributes(this->XMLComparable, this->DocXMLComparable);
				break;

			default:
				break;
			}
		}
	}

	void ComparatorXML::CreateXMLAtributes(XMLAtributes* xml, pugi::xml_document* document)
	{
		// This method create the montage 
		this->CreateMontageAtributes(xml, document);
		this->CreateEventsAtributes(xml, document);
	}

	void ComparatorXML::CreateMontageAtributes(XMLAtributes* xml, pugi::xml_document* document)
	{
		for (pugi::xml_node node : document->child("document").child("montageTable"))
		{
			MontageXML montage;
			montage.Name = node.attribute("name").as_string();
			montage.Save = node.attribute("save").as_bool();
			list<TrackTableXML> list = this->CreateListTrackTableAtributes(node, montage);
			montage.TrackTable = list;
			xml->Montage.push_front(montage);
		}
	}

	list<TrackTableXML> ComparatorXML::CreateListTrackTableAtributes(pugi::xml_node node, MontageXML montage)
	{
		list<TrackTableXML> list;

		for (pugi::xml_node trackTable : node.child("trackTable"))
		{
			TrackTableXML trackTableXML;

			trackTableXML.Label = trackTable.attribute("label").as_string();
			trackTableXML.Color = trackTable.attribute("color").as_string();
			trackTableXML.Amplitude = trackTable.attribute("amplitude").as_double();
			trackTableXML.Hidden = trackTable.attribute("hidden").as_bool();
			trackTableXML.X = trackTable.attribute("x").as_float();
			trackTableXML.Y = trackTable.attribute("y").as_float();
			trackTableXML.Z = trackTable.attribute("z").as_float();
			trackTableXML.Code = trackTable.child_value("code");  
			list.push_front(trackTableXML);
		}

		return list;
	}

	int ComparatorXML::CountMontages(ModelDoc model)
	{
		int mount = 0;

		if (model == ComparatorXML::ModelDoc::EnumXMLDefault)
			mount = this->XMLDefault->Montage.size();

		if (model == ComparatorXML::ModelDoc::EnumXMLComparable)
			mount = this->XMLComparable->Montage.size();

		return mount;
	}

	// Brief this method count the number of elemets inside a list of traks
	// You just have to pass the positin of the montage 
	int ComparatorXML::CountTrackTable(MontageXML montage)
	{
		int mount = 0;
		mount = montage.TrackTable.size();
		return mount;
	}

	void ComparatorXML::CompareDocumentsXML()
	{
		// Clean the object 
		this->CleanXMLAtributes(this->XMLResult);
		int numberMontagesDefault = this->CountMontages(ComparatorXML::ModelDoc::EnumXMLDefault);
		int numberMontagesComparable = this->CountMontages(ComparatorXML::ModelDoc::EnumXMLComparable);
		// This block of code is important because there are diferences betwen the number of track labels
		int diferenceMontages = numberMontagesComparable - numberMontagesDefault;

		// This block count the number of events in every object 
		int numberEventsDefault = this->XMLDefault->EventyType.size();
		int numberEventsComparable = this->XMLComparable->EventyType.size();
		int diferenceEvents = numberEventsComparable - numberEventsDefault;

		// This block of code will be change is just for test 
        // This if is important because you must to know how configuration has more trakcs

		// Condition if there are more montages in the comparable file than defualt.
		if (diferenceMontages <= 0)
		{
			for (size_t i = 0; i < numberMontagesComparable; i++)
			{
				MontageXML montageResult;
				// Counting the number of tracks
				MontageXML montageDefault = this->ReturnMontage(ComparatorXML::ModelDoc::EnumXMLDefault, i);
				MontageXML montageComparable = this->ReturnMontage(ComparatorXML::ModelDoc::EnumXMLComparable, i);
				montageDefault.TrackTable.reverse();
				montageComparable.TrackTable.reverse();

				int diferencesTracks = this->CalculateDiferenceTracks(montageDefault, montageComparable);
				montageResult.Name = montageComparable.Name;
				montageResult.Save = montageComparable.Save;

				// First possibilite the number of tracks are all equals 
				if (diferencesTracks <= 0)
				{
					for (size_t i = 0; i < montageComparable.TrackTable.size(); i++)
					{
						TrackTableXML trackDefault = this->ReturnTrackTable(montageDefault, i);
						TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
						TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackDefault, trackComparable);
						montageResult.TrackTable.push_front(trackTableXMLResult);
					}
				}

				// Second possibilite the number of tracks
				// Second possibilite the number of tracks are diferrent and there are more in comparable than the default 
				if (diferencesTracks > 0)
				{
					for (size_t i = 0; i < montageComparable.TrackTable.size(); i++)
					{
						int numberTrackLabel = montageDefault.TrackTable.size();
				
						if (i  <  numberTrackLabel)
						{
							TrackTableXML trackDefault = this->ReturnTrackTable(montageDefault, i );
							TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
							TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackDefault, trackComparable);
							montageResult.TrackTable.push_front(trackTableXMLResult);
						}
						else
						{
							TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
							TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackComparable);
							montageResult.TrackTable.push_front(trackTableXMLResult);
						}				
					}
				}
							
				XMLResult->Montage.push_front(montageResult);
			}
		}
		
		// Condition if there are less montages in the comparable file than default 
		if (diferenceMontages > 0)
		{
			for (size_t i = 0; i < numberMontagesComparable; i++)
			{
				MontageXML montageResult;

				if (i < numberMontagesDefault)
				{
					 
					// Counting the number of tracks
					MontageXML montageDefault = this->ReturnMontage(ComparatorXML::ModelDoc::EnumXMLDefault, i);
					MontageXML montageComparable = this->ReturnMontage(ComparatorXML::ModelDoc::EnumXMLComparable, i);
					montageDefault.TrackTable.reverse();
					montageComparable.TrackTable.reverse();

					int diferencesTracks = this->CalculateDiferenceTracks(montageDefault, montageComparable);
					montageResult.Name = montageComparable.Name;
					montageResult.Save = montageComparable.Save;

					// First possibilite the number of tracks are all equals 
					if (diferencesTracks <= 0)
					{
						for (size_t i = 0; i < montageComparable.TrackTable.size(); i++)
						{
							TrackTableXML trackDefault = this->ReturnTrackTable(montageDefault, i);
							TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
							TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackDefault, trackComparable);
							montageResult.TrackTable.push_front(trackTableXMLResult);
						}
					}

					// Second possibilite the number of tracks
					// Second possibilite the number of tracks are diferrent and there are more in comparable than the default 	
					if (diferencesTracks > 0)
					{
						for (size_t i = 0; i < montageComparable.TrackTable.size(); i++)
						{
							int numberTrackLabel = montageDefault.TrackTable.size();
							
							if (i  < numberTrackLabel)
							{
								TrackTableXML trackDefault = this->ReturnTrackTable(montageDefault, i);
								TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
								TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackDefault, trackComparable);
								montageResult.TrackTable.push_front(trackTableXMLResult);
							}
							else
							{
								TrackTableXML trackComparable = this->ReturnTrackTable(montageComparable, i);
								TrackTableXML trackTableXMLResult = this->CreateTrackResult(trackComparable);
								montageResult.TrackTable.push_front(trackTableXMLResult);
							}					
						}
					}
				}

				// After this there is no more montages so just copy 
				else
				{
					MontageXML montageComparable = this->ReturnMontage(ComparatorXML::ModelDoc::EnumXMLComparable, i);
					montageResult.Name = montageComparable.Name;
					montageResult.Save = montageComparable.Save;
					montageResult.TrackTable = montageComparable.TrackTable;
				}

				XMLResult->Montage.push_front(montageResult);
			}
		}

		// This block add the events on the result table when there are less elements in the comparable object 
		if(diferenceEvents <= 0)
		{
			for (size_t i = 0; i < this->XMLComparable->EventyType.size(); i++)
			{
				EventTypeXML eventType;
				eventType = this->ReturnEvent(EnumXMLDefault,i);
				this->XMLResult->EventyType.push_back(eventType);
			}
		}

		if(diferenceEvents > 0)
		{
			
			for (size_t i = 0; i < this->XMLComparable->EventyType.size(); i++)
			{

				if(i < this->XMLDefault->EventyType.size())
				{
					EventTypeXML eventType;
					eventType = this->ReturnEvent(EnumXMLDefault, i);
					this->XMLResult->EventyType.push_back(eventType);
				}
					
				else
				{
					EventTypeXML eventType;
					eventType = this->ReturnEvent(EnumXMLComparable, i);
					this->XMLResult->EventyType.push_back(eventType);
				}

			}

		}

	}

	MontageXML ComparatorXML::ReturnMontage(ModelDoc model, int position)
	{
		MontageXML montagePosition;

		if (model == ComparatorXML::ModelDoc::EnumXMLDefault)
		{
			vector<MontageXML> vectorMontage = vector<MontageXML>(this->XMLDefault->Montage.begin(), this->XMLDefault->Montage.end());
			montagePosition = vectorMontage[position];
		}

		if (model == ComparatorXML::ModelDoc::EnumXMLComparable)
		{
			vector<MontageXML>  vectorMontage = vector<MontageXML>(this->XMLComparable->Montage.begin(), this->XMLComparable->Montage.end());
			montagePosition = vectorMontage[position];
		}

		return montagePosition;
	}

	int ComparatorXML::CalculateDiferenceTracks(MontageXML montageDefault, MontageXML montageComparable)
	{
		int tracksNumber = 0;

		int numberDefaultTracks = this->CountTrackTable(montageDefault);
		int numberComparableTracks = this->CountTrackTable(montageComparable);
		tracksNumber = numberComparableTracks - numberDefaultTracks;

		return tracksNumber;
	}

	TrackTableXML ComparatorXML::ReturnTrackTable(MontageXML montage, int position)
	{
		TrackTableXML trackTable;

		if ((montage.TrackTable.size() >= position) && (montage.TrackTable.size() > 0))
		{
			vector<TrackTableXML>  vectorTrackTable = vector<TrackTableXML>(montage.TrackTable.begin(), montage.TrackTable.end());
			trackTable = vectorTrackTable[position];
		}

		return trackTable;
	}

    TrackTableXML ComparatorXML::CreateTrackResult(TrackTableXML defaultXML, TrackTableXML comparable)
	{
		TrackTableXML result;

		result.Label = comparable.Label;
		result.Code = comparable.Code;
		// Track
        result.Amplitude = defaultXML.Amplitude;
        result.Color = defaultXML.Color;
        result.Hidden = defaultXML.Hidden;
        result.X = defaultXML.X;
        result.Y = defaultXML.Y;
        result.Z = defaultXML.Z;

		return result;
	}

	TrackTableXML ComparatorXML::CreateTrackResult(TrackTableXML comparable)
	{
		TrackTableXML result;

		result.Label = comparable.Label;
		result.Code = comparable.Code;
		result.Amplitude = comparable.Amplitude;
		result.Color = comparable.Color;
		result.Label = comparable.Label;
		result.X = comparable.X;
		result.Y = comparable.Y;
		result.Z = comparable.Z;

		return result;
	}

	void ComparatorXML::CleanXMLAtributes(XMLAtributes* xmlAtributes)
	{
		xmlAtributes->Montage.clear();
	}

	int ComparatorXML::RevertPosition(int numberTracks, int position)
	{
		int positionVector = 0;

		if (numberTracks == 0)
			return 0;

		positionVector = numberTracks - position -1 ;

		if (positionVector < 0)
			positionVector = 0;

		return positionVector;
	}

	list<MontageXML> ComparatorXML::ReturnResultMontage()
	{
		return this->XMLResult->Montage;
	}

	TrackTableXML ComparatorXML::ReturnTrackTableFromResult(int montagePosition, int trackPosition)
	{
		TrackTableXML trackTableXML;

		list<MontageXML> montageList = this->XMLResult->Montage;		
		vector<MontageXML>  vectorTrackMontage = vector<MontageXML>(montageList.begin(), montageList.end());
		MontageXML montage = vectorTrackMontage[montagePosition];

		list<TrackTableXML> trackList = montage.TrackTable;
		trackList.reverse();
		vector<TrackTableXML> vectorTrackTable = vector<TrackTableXML>(trackList.begin(), trackList.end());
	    trackTableXML = vectorTrackTable[trackPosition];

		return trackTableXML;
	}

	void ComparatorXML::CreateEventsAtributes(XMLAtributes* xml, pugi::xml_document* document)
	{
		for (pugi::xml_node node : document->child("document").child("eventTypeTable"))
		{
			EventTypeXML eventType;
			eventType.Id = node.attribute("id").as_int();
			eventType.Name = node.attribute("name").as_string();
			eventType.Opacity = node.attribute("opacity").as_double();
			eventType.Color = node.attribute("color").as_string();
			eventType.Hidden = node.attribute("hidden").as_bool();
			xml->EventyType.push_back(eventType);
		}
	}

	EventTypeXML ComparatorXML::ReturnEvent(ModelDoc model, int position)
	{
		EventTypeXML eventType;

		if(model == EnumXMLDefault)
		{
			list<EventTypeXML> listEventsDefault = this->XMLDefault->EventyType;

			if(listEventsDefault.size() > position)
			{
				vector<EventTypeXML> vectorEventDefault = vector<EventTypeXML>(listEventsDefault.begin(), listEventsDefault.end());
				eventType = vectorEventDefault[position];
			}
		}

		if(model == EnumXMLComparable)
		{
			list<EventTypeXML> listEventsComparable = this->XMLComparable->EventyType;

			if(listEventsComparable.size() > position)
			{
				vector<EventTypeXML> vectorEventComparable = vector<EventTypeXML>(listEventsComparable.begin(), listEventsComparable.end());
				eventType = vectorEventComparable[position];
			}
		}

		return eventType;
	}

	list<EventTypeXML> ComparatorXML::ReturnResultEvents()
	{		
		return this->XMLResult->EventyType;
	}

	EventTypeXML ComparatorXML::ReturnEventFromResult(int position)
	{
		EventTypeXML eventType;

		vector<EventTypeXML> eventTypeVector = vector<EventTypeXML>(this->XMLResult->EventyType.begin(), this->XMLResult->EventyType.end());

		if (eventTypeVector.size() > position)
			eventType = eventTypeVector[position];

		return eventType;
	}

    list<MontageXML> ComparatorXML::ReturnMontageComparable()
    {
        return this->XMLComparable->Montage;
    }


    list<EventTypeXML> ComparatorXML::ReturnEventComparable()
    {
        return this->XMLComparable->EventyType;
    }



