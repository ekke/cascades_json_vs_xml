/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>

#include <bb/data/JsonDataAccess>
#include <bb/data/XmlDataAccess>

#include <bb/data/SqlDataAccess>
#include <bb/data/DataAccessError>
#include <QtSql/QtSql>

#include <QTimer>

const QString DB_NAME = "testdata.db";
const QString ADR_TABLE_NAME = "addresses";
const QString SPEAKER_TABLE_NAME = "speakers";

static QString dataPath(const QString& fileName) {
	return QDir::currentPath() + "/data/" + fileName;
}

static QString assetsXMLPath(const QString& fileName) {
	return QDir::currentPath() + "/app/native/assets/xml_data/" + fileName;
}

static QString assetsJSONPath(const QString& fileName) {
	return QDir::currentPath() + "/app/native/assets/json_data/" + fileName;
}

using namespace bb::cascades;
using namespace bb::data;

ApplicationUI::ApplicationUI(bb::cascades::Application *app) :
		QObject(app) {
	// prepare the localization
	m_pTranslator = new QTranslator(this);
	m_pLocaleHandler = new LocaleHandler(this);

	bool res = QObject::connect(m_pLocaleHandler,
			SIGNAL(systemLanguageChanged()), this,
			SLOT(onSystemLanguageChanged()));
	// This is only available in Debug builds
	Q_ASSERT(res);

	// Since the variable is not used in the app, this is added to avoid a
	// compiler warning
	Q_UNUSED(res);

	// initial load
	onSystemLanguageChanged();

	// init the sqlite database
	mDatabaseAvailable = initDatabase();

	// QTimer
	qmlRegisterType<QTimer>("my.library", 1, 0, "QTimer");

	// Create scene document from main.qml asset, the parent is set
	// to ensure the document gets destroyed properly at shut down.
	QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);

	// access to the Application
	qml->setContextProperty("app", this);

	// Create root object for the UI
	AbstractPane *root = qml->createRootObject<AbstractPane>();

	// Set created root object as the application scene
	app->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged() {
	QCoreApplication::instance()->removeTranslator(m_pTranslator);
	// Initiate, load and install the application translation files.
	QString locale_string = QLocale().name();
	QString file_name = QString("cascades_JSONvsXML_%1").arg(locale_string);
	if (m_pTranslator->load(file_name, "app/native/qm")) {
		QCoreApplication::instance()->installTranslator(m_pTranslator);
	}
}

void ApplicationUI::compareJSONandXMLspeaker() {
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	QString filenameXML;
	XmlDataAccess xda;
	QTime time;
	filenameXML = "speaker.xml";
	QFile dataFile2(assetsXMLPath(filenameXML));
	time.start();
	dataFile2.open(QIODevice::ReadOnly);
	data = xda.loadFromBuffer(dataFile2.readAll());
	int elapsed2 = time.elapsed();
	//
	filenameJSON = "speaker.json";
	QFile dataFile1(assetsJSONPath(filenameJSON));
	time.start();
	dataFile1.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile1.readAll());
	int elapsed1 = time.elapsed();
	//
	filenameJSON = "speakerlist.json";
	QFile dataFile3(assetsJSONPath(filenameJSON));
	time.start();
	dataFile3.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile3.readAll());
	int elapsed3 = time.elapsed();
	qDebug() << "1: READ JSON " << elapsed1 << " 2: READ XML " << elapsed2
			<< " 3: READ JSON converted " << elapsed3;
	int maxValue;
	maxValue = std::max(elapsed1, elapsed2);
	maxValue = std::max(maxValue, elapsed3);
	emit speedTestSpeaker(maxValue, elapsed2, elapsed1, elapsed3);
}

void ApplicationUI::compareJSONandXMLaddresses() {
	// attention: no checks done if file exists, could be read or written
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	QString filenameXML;
	XmlDataAccess xda;
	QTime time;

	// READ XML
	filenameXML = "addresses_us.xml";
	QFile dataFile2(assetsXMLPath(filenameXML));
	time.start();
	dataFile2.open(QIODevice::ReadOnly);
	data = xda.loadFromBuffer(dataFile2.readAll());
	int elapsedReadXML = time.elapsed();

	// WRITE XML
	filenameXML = "addresses_us.xml";
	time.start();
	xda.save(data, dataPath(filenameXML));
	int elapsedWriteXML = time.elapsed();

	// READ JSON
	filenameJSON = "addresses_us.json";
	QFile dataFile1(assetsJSONPath(filenameJSON));
	time.start();
	dataFile1.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile1.readAll());
	int elapsedReadJSON = time.elapsed();

	// WRITE JSON
	filenameJSON = "addresses_us.json";
	time.start();
	jda.save(data, dataPath(filenameJSON));
	int elapsedWriteJSON = time.elapsed();

	// READ WRITE SQL
	QList<int> measuredTimes = readWriteSQLaddresses();

	qDebug() << "1: READ JSON " << elapsedReadJSON << " 2: WRITE JSON "
			<< elapsedWriteJSON << " 3: READ XML " << elapsedReadXML
			<< " 4: WRITE XML " << elapsedWriteXML << " 5: READ SQL "
			<< measuredTimes.at(0) << " 6: WRITE SQL " << measuredTimes.at(1);
	int maxValue;
	maxValue = std::max(elapsedReadJSON, elapsedWriteJSON);
	maxValue = std::max(maxValue, elapsedReadXML);
	maxValue = std::max(maxValue, elapsedWriteXML);
	maxValue = std::max(maxValue, measuredTimes.at(0));
	maxValue = std::max(maxValue, measuredTimes.at(1));
	emit speedTestAddresses(maxValue, elapsedReadJSON, elapsedWriteJSON,
			elapsedReadXML, elapsedWriteXML, measuredTimes.at(0),
			measuredTimes.at(1));
}

void ApplicationUI::convertJSONtoXMLAddresses() {
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	filenameJSON = "addresses_us.json";
	QFile dataFile(assetsJSONPath(filenameJSON));
	if (!dataFile.exists()) {
		// do something
		qWarning() << "addresses_us.json not found";
		return;
	}
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = jda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameJSON;
	}
	QString filenameXML;
	filenameXML = "addresses_us.xml";
	// QVariant data = xda.load
	XmlDataAccess xda;
	xda.save(data, dataPath(filenameXML));
	qDebug() << "finished converting";
	emit conversionDone();
}

void ApplicationUI::convertXMLtoJSONAddresses() {
	XmlDataAccess xda;
	QVariant data;
	QString filenameXML;
	filenameXML = "addresses_us.xml";
	QFile dataFile(assetsXMLPath(filenameXML));
	if (!dataFile.exists()) {
		// do something
		qWarning() << "addresses_us.xml not found";
		return;
	}
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = xda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameXML;
	}
	QString filenameJSON;
	filenameJSON = "addresses_us.json";
	// QVariant data = xda.load
	JsonDataAccess jda;
	jda.save(data, dataPath(filenameJSON));
	qDebug() << "finished converting";
	emit conversionDone();
}

void ApplicationUI::convertXMLtoJSONspeaker() {
	XmlDataAccess xda;
	QVariant data;
	QString filenameXML;
	filenameXML = "speaker.xml";
	QFile dataFileSpeaker(assetsXMLPath(filenameXML));
	if (!dataFileSpeaker.exists()) {
		// do something
		return;
	}
	bool ok = dataFileSpeaker.open(QIODevice::ReadOnly);
	if (ok) {
		data = xda.loadFromBuffer(dataFileSpeaker.readAll());
		dataFileSpeaker.close();
	} else {
		qDebug() << "cannot read data file: " << filenameXML;
	}
	// write the file without converting
	QString filenameJSON = "speaker.json";
	JsonDataAccess jda;
	jda.save(data, dataPath(filenameJSON));
	// now convert
	QTime timer;
	timer.start();
	convertSpeaker(data);
	filenameJSON = "speakerlist.json";
	jda.save(data, dataPath(filenameJSON));
	int timeToConvertAndWrite = timer.elapsed();
	qDebug() << "finished converting speaker: " << timeToConvertAndWrite;
	emit conversionDone();
}

void ApplicationUI::convertSpeaker(QVariant& data) {
	QVariantMap rootMap = data.toMap();
	QVariantMap channelMap = rootMap.value("channel").toMap();
	QVariantList itemList = channelMap.value("item").toList();
	QVariantList speakerList;
	for (int i = 0; i < itemList.size(); ++i) {
		QVariantMap itemMap = itemList.at(i).toMap();
		QVariantMap guidMap = itemMap.value("guid").toMap();
		QString guid = guidMap.value(".data").toString().split("=").last();
		int id = guid.toInt();
		QVariantList metaList = itemMap.value("wp:postmeta").toList();
		QVariantMap speakerMap;
		speakerMap.insert("id", id);
		speakerMap.insert("bio", itemMap.value("content:encoded"));
		speakerMap.insert("name", itemMap.value("title"));
		for (int m = 0; m < metaList.size(); ++m) {
			QVariantMap metaMap = metaList.at(m).toMap();
			QString metaKey = metaMap.value("wp:meta_key").toString();
			if (metaKey == "wpcf-speaker-company") {
				speakerMap.insert("company", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-intro") {
				speakerMap.insert("intro", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-xing") {
				speakerMap.insert("xing", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-blog") {
				speakerMap.insert("blog", metaMap.value("wp:meta_value"));
				continue;
			}
			if (metaKey == "wpcf-speaker-foto") {
				speakerMap.insert("foto", metaMap.value("wp:meta_value"));
				continue;
			}
		}
		speakerList.append(speakerMap);
	}
	data = speakerList;
}

//  S Q L
/**
 * (Creates if not exists and) OPENs the DATABASE FILE
 * from sandbox/data
 * Also initialized the DATABASE CONNECTION (SqlDataAccess),
 * we're reusing for all SQL commands on this database
 *
 * ATTENTION: This APP was written to test the READ / WRITE speed
 * in a real APP you have to test better for errors
 * Also when constructing statements in a loop, you should use some constants
 */
bool ApplicationUI::initDatabase() {
	QSqlDatabase database = QSqlDatabase::addDatabase("QSQLITE");
	database.setDatabaseName(dataPath(DB_NAME));
	if (database.open() == false) {
		const QSqlError error = database.lastError();
		// you should notify the user !
		qWarning() << "Cannot open testdata.db " << error.text();
		return false;
	}
	qDebug() << "Database testdata.db opened";
	// create the Connection
	mSQLda = new SqlDataAccess(dataPath(DB_NAME), this);
	return true;
}

/**
 * Measure the time it needs to READ data from SQL
 * and to WRITE data to SQL
 * READ was done by SELECT *
 * WRITE was done DROPPING the TABLE, CREATE TABLE
 * and then doing a BATCH INSERT of all records
 *
 * If no TABLE exists, the data was read from JSON
 * and inserted
 */
QList<int> ApplicationUI::readWriteSQLaddresses() {
	QTime time;
	QList<int> measuredTimes;
	// READ all from SQL
	time.start();
	QString sqlQuery = "SELECT * FROM " + ADR_TABLE_NAME;
	QVariant result = mSQLda->execute(sqlQuery);
	int count = result.toList().size();
	// if there's no TABLE we get back an empty result
	if (count == 0) {
		// we have to convert the data from JSON
		firstInitSqliteAddresses();
		// Start again to READ all from SQL
		time.start();
		result = mSQLda->execute(sqlQuery);
	}
	// If the Database has no TABLE for addresses, it will fail
	// in this case we'll read from JSON and INSERT into DB
	if (mSQLda->hasError()) {
		qDebug() << "DataAccessError: " << mSQLda->error().errorMessage();
		measuredTimes << 0 << 0;
		return measuredTimes;
	}
	count = result.toList().size();
	if (count == 0) {
		// cannot go on without data. Notify the user !
		qWarning() << "No DATA READ from SQL";
		measuredTimes << 0 << 0;
		return measuredTimes;
	}
	// qDebug() << "READ from SQL count: " << count;
	int timeToReadFromTable = time.elapsed();

	// WRITE back to SQL
	// now to write all data from QVariantList back into SQL:
	// 1. DROP the existing TABLE
	time.start();
	mSQLda->execute("DROP TABLE IF EXISTS " + ADR_TABLE_NAME);
	if (!mSQLda->hasError()) {
		qDebug() << "Addresses Table DROPPED.";
	} else {
		qWarning() << "Drop table Addresses Error "
				<< mSQLda->error().errorMessage();
		// we're optimistic and ignore this and go on
	}
	int timeToDropTable = time.elapsed();
	// 2. CREATE the TABLE, then
	// 3. INSERT all Records from QVariantList we got before
	time.start();
	// CREATE TABLE!
	createAndInsertAddressesFromList(result.toList());
	int timeToInsert = time.elapsed();
	qDebug() << "READ FROM SQL: " << timeToReadFromTable << " DROP TABLE: "
			<< timeToDropTable << " INSERT SQL: " << timeToInsert;
	measuredTimes << timeToReadFromTable << timeToDropTable + timeToInsert;
	return measuredTimes;
}

QList<int> ApplicationUI::readWriteSQLspeakers() {
	QTime time;
	QList<int> measuredTimes;
	// READ all from SQL
	time.start();
	QString sqlQuery = "SELECT * FROM " + SPEAKER_TABLE_NAME;
	QVariant result = mSQLda->execute(sqlQuery);
	int count = result.toList().size();
	// if there's no TABLE we get back an empty result
	if (count == 0) {
		// we have to convert the data from JSON
		firstInitSqliteSpeakers();
		// Start again to READ all from SQL
		time.start();
		result = mSQLda->execute(sqlQuery);
	}
	if (mSQLda->hasError()) {
		qDebug() << "DataAccessError: " << mSQLda->error().errorMessage();
		measuredTimes << 0 << 0;
		return measuredTimes;
	}
	count = result.toList().size();
	if (count == 0) {
		// cannot go on without data. Notify the user !
		qWarning() << "No DATA READ from SQL";
		measuredTimes << 0 << 0;
		return measuredTimes;
	}
	// qDebug() << "READ from SQL count: " << count;
	int timeToReadFromTable = time.elapsed();
	// WRITE back to SQL
	// now to write all data from QVariantList back into SQL:
	// 1. DROP the existing TABLE
	time.start();
	mSQLda->execute("DROP TABLE IF EXISTS " + SPEAKER_TABLE_NAME);
	if (!mSQLda->hasError()) {
		qDebug() << "Speakers Table DROPPED.";
	} else {
		qWarning() << "Drop table Speakers Error "
				<< mSQLda->error().errorMessage();
		// we're optimistic and ignore this and go on
	}
	int timeToDropTable = time.elapsed();
	// 2. CREATE the TABLE, then
	// 3. INSERT all Records from QVariantList we got before
	time.start();
	// CREATE TABLE!
	createAndInsertSpeakersFromList(result.toList());
	int timeToInsert = time.elapsed();
	qDebug() << "READ FROM SQL: " << timeToReadFromTable << " DROP TABLE: "
			<< timeToDropTable << " INSERT SQL: " << timeToInsert;
	measuredTimes << timeToReadFromTable << timeToDropTable + timeToInsert;
	return measuredTimes;
}

void ApplicationUI::compareJSONandSQLspeakers() {
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	XmlDataAccess xda;
	QTime time;

	// READ JSON
	filenameJSON = "speakerlist.json";
	QFile dataFile1(assetsJSONPath(filenameJSON));
	time.start();
	dataFile1.open(QIODevice::ReadOnly);
	data = jda.loadFromBuffer(dataFile1.readAll());
	int elapsedReadJSON = time.elapsed();

	// WRITE JSON
	filenameJSON = "speakerlist.json";
	time.start();
	jda.save(data, dataPath(filenameJSON));
	int elapsedWriteJSON = time.elapsed();

	// READ WRITE SQL
	QList<int> measuredTimes = readWriteSQLspeakers();

	qDebug() << "1: READ JSON " << elapsedReadJSON << " 2: WRITE JSON "
			<< elapsedWriteJSON << " 3: READ SQL " << measuredTimes.at(0)
			<< " 4: WRITE SQL " << measuredTimes.at(1);
	int maxValue;
	maxValue = std::max(elapsedReadJSON, elapsedWriteJSON);
	maxValue = std::max(maxValue, measuredTimes.at(0));
	maxValue = std::max(maxValue, measuredTimes.at(1));
	emit speedTestSpeakerSQL(maxValue, elapsedReadJSON, elapsedWriteJSON,
			measuredTimes.at(0), measuredTimes.at(1));
}

/**
 * From a QVariantList you got from JSON or SQL Query
 * a new TABLE was CREATED using the QVariantMap keys,
 * then all QVariantMap were inserted into the TABLE addresses
 */
void ApplicationUI::createAndInsertAddressesFromList(
		const QVariantList& allAddresses) {
	int count = allAddresses.size();
	if (count == 0) {
		qDebug() << "NO DATA for Addresses in List";
		return;
	}
	// to be safe we drop an existing table
	mSQLda->execute("DROP TABLE IF EXISTS " + ADR_TABLE_NAME);
	// now CREATE TABLE
	QVariantMap addressMap;
	addressMap = allAddresses.at(0).toMap();
	QString createSQL = createTableCommandForAddresses(addressMap);
	// qDebug() << createSQL;
	mSQLda->execute(createSQL);
	if (!mSQLda->hasError()) {
		qDebug() << "Table Addresses created.";
	} else {
		qWarning() << "Create table Addresses Error "
				<< mSQLda->error().errorMessage();
		return;
	}
	// Now we have created the Addresses TABLE
	// As next let us insert the data
	QString insertSQL = createParameterizedInsertCommand(addressMap,
			ADR_TABLE_NAME);
	// HINT: this executeBatch command automatically runs in a TRANSACTION to get best results
	mSQLda->executeBatch(insertSQL, allAddresses);
	if (!mSQLda->hasError()) {
		qDebug() << "Records into Addresses inserted.";
	} else {
		qWarning() << "Insert into Addresses Error "
				<< mSQLda->error().errorMessage();
		return;
	}
}

/**
 * From a QVariantList you got from JSON or SQL Query
 * a new TABLE was CREATED using the QVariantMap keys,
 * then all QVariantMap were inserted into the TABLE speakers
 */
void ApplicationUI::createAndInsertSpeakersFromList(
		const QVariantList& allSpeakers) {
	int count = allSpeakers.size();
	if (count == 0) {
		qDebug() << "NO DATA for Speakers in List";
		return;
	}
	// to be safe we drop an existing table
	mSQLda->execute("DROP TABLE IF EXISTS " + SPEAKER_TABLE_NAME);
	// now CREATE TABLE
	QVariantMap speakerMap;
	speakerMap = allSpeakers.at(0).toMap();
	QString createSQL = createTableCommandForSpeakers(speakerMap);
	// qDebug() << createSQL;
	mSQLda->execute(createSQL);
	if (!mSQLda->hasError()) {
		qDebug() << "Table Speakers created.";
	} else {
		qWarning() << "Create table Speakers Error "
				<< mSQLda->error().errorMessage();
		return;
	}
	// Now we have created the Speakers TABLE
	// As next let us insert the data
	QString insertSQL = createParameterizedInsertCommand(speakerMap,
			SPEAKER_TABLE_NAME);
	// HINT: this executeBatch command automatically runs in a TRANSACTION to get best results
	mSQLda->executeBatch(insertSQL, allSpeakers);
	if (!mSQLda->hasError()) {
		qDebug() << "Records into Speakers inserted.";
	} else {
		qWarning() << "Insert into Speakers Error "
				<< mSQLda->error().errorMessage();
		return;
	}
}

/**
 * Creates the SQL command for
 * CREATE TABLE for addresses
 * gets all column names from QVariantMap - keys
 */
QString ApplicationUI::createTableCommandForAddresses(
		const QVariantMap& addressMap) {
	QStringList allAddressColumns = addressMap.keys();
	QString createSQL = "CREATE TABLE " + ADR_TABLE_NAME + " (";
	for (int i = 0; i < allAddressColumns.size(); ++i) {
		QString colName;
		colName = allAddressColumns.at(i);
		createSQL += colName;
		if (colName == "Number") {
			createSQL += " INTEGER PRIMARY KEY";
		} else if (colName == "Latitude" || colName == "Longitude") {
			createSQL += " DOUBLE";
		} else {
			createSQL += " TEXT";
		}
		if (i == (allAddressColumns.size() - 1)) {
			createSQL += ");";
		} else {
			createSQL += ", ";
		}
	}
	return createSQL;
}

/**
 * Creates the SQL command for
 * CREATE TABLE for speakers
 * gets all column names from QVariantMap - keys
 */
QString ApplicationUI::createTableCommandForSpeakers(
		const QVariantMap& speakerMap) {
	QStringList allSpeakerColumns = speakerMap.keys();
	QString createSQL = "CREATE TABLE " + SPEAKER_TABLE_NAME + " (";
	for (int i = 0; i < allSpeakerColumns.size(); ++i) {
		QString colName;
		colName = allSpeakerColumns.at(i);
		createSQL += colName;
		if (colName == "id") {
			createSQL += " INTEGER PRIMARY KEY";
		} else {
			createSQL += " TEXT";
		}
		if (i == (allSpeakerColumns.size() - 1)) {
			createSQL += ");";
		} else {
			createSQL += ", ";
		}
	}
	return createSQL;
}

/**
 * Creates the SQL command for
 * INSERT into a TABLE using parameterized values
 * all column names from QVariantMap - keys
 */
QString ApplicationUI::createParameterizedInsertCommand(
		const QVariantMap& rowMap, const QString& tableName) {
	QStringList allColumns = rowMap.keys();
	QString insertSQL;
	QString valueSQL;
	insertSQL = "INSERT INTO " + tableName + " (";
	valueSQL = " VALUES (";
	for (int i = 0; i < allColumns.size(); ++i) {
		insertSQL += allColumns.at(i);
		valueSQL += ":";
		valueSQL += allColumns.at(i);
		if (i == (allColumns.size() - 1)) {
			insertSQL += ") ";
			valueSQL += ") ";
		} else {
			insertSQL += ", ";
			valueSQL += ", ";
		}
	}
	// qDebug() << insertSQL;
	// qDebug() << valueSQL;
	insertSQL += valueSQL;
	return insertSQL;
}

/**
 * If there's no TABLE for addresses:
 * Read in JSON data from assets
 * CREATE the TABLE and INSERT all data
 */
void ApplicationUI::firstInitSqliteAddresses() {
	// READ from JSON
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	filenameJSON = "addresses_us.json";
	QFile dataFile(assetsJSONPath(filenameJSON));
	if (!dataFile.exists()) {
		qWarning() << "addresses_us.json not found";
		return;
	}
	qDebug() << "get the JSON data";
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = jda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameJSON;
		return;
	}
	// CREATE TABLE
	// now we need the column names to create the Table
	// this will only work if every record contains all columns !
	QVariantList allJSONData = data.toMap().value("Address").toList();
	createAndInsertAddressesFromList(allJSONData);
}

/**
 * If there's no TABLE for speakers:
 * Read in JSON data from assets
 * CREATE the TABLE and INSERT all data
 */
void ApplicationUI::firstInitSqliteSpeakers() {
	// READ from JSON
	JsonDataAccess jda;
	QVariant data;
	QString filenameJSON;
	filenameJSON = "speakerlist.json";
	QFile dataFile(assetsJSONPath(filenameJSON));
	if (!dataFile.exists()) {
		qWarning() << "speakerlist.json not found";
		return;
	}
	qDebug() << "get the JSON data";
	bool ok = dataFile.open(QIODevice::ReadOnly);
	if (ok) {
		data = jda.loadFromBuffer(dataFile.readAll());
		dataFile.close();
	} else {
		qDebug() << "cannot read data file: " << filenameJSON;
		return;
	}
	// CREATE TABLE
	// now we need the column names to create the Table
	// this will only work if every record contains all columns !
	QVariantList allJSONData = data.toList();
	// ATTENTION:
	// the list of speakers contains QVariantMaps with different
	// properties. we can work with this from JsonDataAccess, but we cannot
	// use it for a parameterized statement.
	// so at first we have to make them equal
	if (allJSONData.size() == 0) {
		// cannot use it
		return;
	}
	QTime timer;
	timer.start();
	bool allOK = false;
	QStringList maxKeysList = allJSONData.at(0).toMap().keys();
	while (!allOK) {
		for (int i = 0; i < allJSONData.size(); ++i) {
			// test if keys are missing
			QVariantMap speakerMap;
			speakerMap = allJSONData.at(i).toMap();
			bool insertedMissingKeys = false;
			for (int sk = 0; sk < maxKeysList.size(); ++sk) {
				if (!speakerMap.contains(maxKeysList.at(sk))) {
					speakerMap.insert(maxKeysList.at(sk), "");
					insertedMissingKeys = true;
				}
			}
			// if missing keys found, replace the map in the list
			if (insertedMissingKeys) {
				allJSONData.replace(i, speakerMap);
			}
			// no test if there are more keys
			if (speakerMap.keys().size() > maxKeysList.size()) {
				maxKeysList = speakerMap.keys();
				// do it all again from beginning
				break;
			}
			if (i == (allJSONData.size() - 1)) {
				// YEP: all are equal from keys
				allOK = true;
			}
		}
	}
	int timeToMakeMapsEqual = timer.elapsed();
	qDebug() << "made SPEAKER MAPs equal: " << timeToMakeMapsEqual;
	// no go on as usual
	createAndInsertSpeakersFromList(allJSONData);
}
