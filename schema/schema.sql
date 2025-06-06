/*
        Create verifiable incident table.
*/
CREATE TABLE IF NOT EXISTS incident
(
    id SERIAL PRIMARY KEY,
    victim_address VARCHAR (255),
    victim_name VARCHAR (255),
    killer_address VARCHAR(255),
    killer_name VARCHAR(255),
    solar_system_id BIGINT,
    loss_type VARCHAR(255),
    time_stamp BIGINT,
    UNIQUE (victim_name, time_stamp)
);
/*
        Create systems table.
*/
CREATE TABLE IF NOT EXISTS systems
(
   id SERIAL PRIMARY KEY,
   solar_system_id BIGINT,
   solar_system_name VARCHAR(255),
   x TEXT,
   y TEXT,
   z TEXT
);
/*
        Create a trigger.
*/
CREATE TRIGGER incident_notify_trigger
AFTER INSERT ON incident
FOR EACH ROW
EXECUTE FUNCTION notify_incident_trigger();
/*
        Send payload to a listener channel.
*/
CREATE OR REPLACE FUNCTION notify_incident_trigger()
RETURNS trigger AS $$
DECLARE
    payload TEXT;
BEGIN
    -- Convert the new row to a JSON string
    payload := row_to_json(NEW)::text;
    -- Send the notification to the 'incident_trigger' channel with the payload
    PERFORM pg_notify('incident_trigger', payload);   
    -- Return the new row so that the insertion completes normally
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
      Precomputed index to speed up requests related to time filtration, LDAP format.
*/
CREATE INDEX idx_incident_converted_ts
ON incident (to_timestamp((time_stamp - 116444736000000000) / 10000000.0));
/*
      Precomputed index to speed up requests regarding name search for totals.
*/
CREATE INDEX idx_incident_killer ON incident (killer_name);
CREATE INDEX idx_incident_victim ON incident (victim_name);
